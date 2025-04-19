import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_management/bloc/user_event.dart';
import 'package:flutter_user_management/bloc/user_state.dart';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/data/repositories/user_repository.dart';
import 'package:flutter_user_management/utils/app_constants.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<User> _currentUsers = [];
  String? _currentSearchQuery;
  
  UserBloc({UserRepository? userRepository}) 
      : _userRepository = userRepository ?? UserRepository(),
        super(const UserInitial()) {
    on<FetchUserList>(_onFetchUserList);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<FetchUserDetails>(_onFetchUserDetails);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
    on<SyncChanges>(_onSyncChanges);
    on<RefreshUserData>(_onRefreshUserData);
  }
  
  Future<void> _onFetchUserList(
    FetchUserList event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Reset pagination if starting from page 1
      if (event.page == 1) {
        _currentPage = 1;
        _hasReachedMax = false;
        _currentUsers = [];
        _currentSearchQuery = null;
        
        emit(const UserListLoading());
      }
      
      final users = await _userRepository.getUsers(
        page: event.page, 
        forceRefresh: event.forceRefresh,
      );
      
      _currentUsers = users;
      _currentPage = event.page;
      
      // Check if we've reached the end (less than page size)
      if (users.length < AppConstants.defaultPageSize) {
        _hasReachedMax = true;
      }
      
      emit(UserListLoaded(
        users: users,
        hasReachedMax: _hasReachedMax,
        currentPage: _currentPage,
      ));
    } on UserRepositoryException catch (e) {
      emit(UserListError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Don't load more if already at max
      if (_hasReachedMax) return;
      
      // Show loading state
      emit(UserLoadingMore(currentUsers: _currentUsers));
      
      final nextPage = _currentPage + 1;
      
      List<User> newUsers;
      if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
        // If in search mode, search with next page
        newUsers = await _userRepository.searchUsers(_currentSearchQuery!);
        // For search, we typically load all results at once,
        // so mark as reached max after first load
        _hasReachedMax = true;
      } else {
        // Otherwise get next page of all users
        newUsers = await _userRepository.getUsers(page: nextPage);
        
        // Check if reached max
        if (newUsers.length < AppConstants.defaultPageSize) {
          _hasReachedMax = true;
        }
      }
      
      // Update current state
      _currentPage = nextPage;
      _currentUsers = [..._currentUsers, ...newUsers];
      
      emit(UserListLoaded(
        users: _currentUsers,
        hasReachedMax: _hasReachedMax,
        currentPage: _currentPage,
        searchQuery: _currentSearchQuery,
      ));
    } on UserRepositoryException catch (e) {
      emit(UserListError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }
  
  Future<void> _onFetchUserDetails(
    FetchUserDetails event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserDetailsLoading());
      
      final user = await _userRepository.getUserById(event.userId);
      
      emit(UserDetailsLoaded(user: user));
    } on UserRepositoryException catch (e) {
      emit(UserDetailsError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserDetailsError(message: e.toString()));
    }
  }
  
  Future<void> _onAddUser(
    AddUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserListLoaded) {
        emit(UserActionLoading(previousState: state));
      } else {
        emit(const UserListLoading());
      }
      
      final createdUser = await _userRepository.createUser(event.user);
      
      emit(UserAddSuccess(user: createdUser));
      
      // Refresh the list to include the new user
      add(const FetchUserList(page: 1, forceRefresh: true));
    } on UserRepositoryException catch (e) {
      emit(UserAddError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserAddError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserListLoaded || state is UserDetailsLoaded) {
        emit(UserActionLoading(previousState: state));
      } else {
        emit(const UserListLoading());
      }
      
      final updatedUser = await _userRepository.updateUser(event.user);
      
      emit(UserUpdateSuccess(user: updatedUser));
      
      // Update the current state
      if (state is UserListLoaded) {
        // Find and update the user in the list
        final index = _currentUsers.indexWhere(
          (user) => user.id == updatedUser.id
        );
        
        if (index >= 0) {
          _currentUsers[index] = updatedUser;
          emit(UserListLoaded(
            users: List.from(_currentUsers),
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
            searchQuery: _currentSearchQuery,
          ));
        } else {
          // If user not in the list, reload
          add(const FetchUserList(page: 1, forceRefresh: true));
        }
      } else if (state is UserDetailsLoaded) {
        // Update the details view
        emit(UserDetailsLoaded(user: updatedUser));
      }
    } on UserRepositoryException catch (e) {
      emit(UserUpdateError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserUpdateError(message: e.toString()));
    }
  }
  
  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserListLoaded) {
        emit(UserActionLoading(previousState: state));
      } else {
        emit(const UserListLoading());
      }
      
      await _userRepository.deleteUser(event.userId);
      
      emit(UserDeleteSuccess(userId: event.userId));
      
      // Update the current state if it's a list
      if (state is UserListLoaded || state is UserActionLoading) {
        // Remove user from local list
        _currentUsers.removeWhere((user) => user.id == event.userId);
        
        emit(UserListLoaded(
          users: List.from(_currentUsers),
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
          searchQuery: _currentSearchQuery,
        ));
      }
    } on UserRepositoryException catch (e) {
      emit(UserDeleteError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserDeleteError(message: e.toString()));
    }
  }
  
  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserListLoading());
      
      _currentSearchQuery = event.query;
      _currentPage = 1;
      _hasReachedMax = false;
      
      final users = await _userRepository.searchUsers(event.query);
      
      _currentUsers = users;
      
      // For search, we typically load all results at once
      _hasReachedMax = true;
      
      emit(UserListLoaded(
        users: users,
        hasReachedMax: true,
        currentPage: 1,
        searchQuery: event.query,
      ));
    } on UserRepositoryException catch (e) {
      emit(UserListError(
        message: e.message,
        isNetworkError: e.isNetworkError,
      ));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }
  
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<UserState> emit,
  ) async {
    _currentSearchQuery = null;
    add(const FetchUserList(page: 1));
  }
  
  Future<void> _onSyncChanges(
    SyncChanges event,
    Emitter<UserState> emit,
  ) async {
    try {
      final currentState = state;
      emit(UserActionLoading(previousState: currentState));
      
      final success = await _userRepository.syncLocalChanges();
      
      if (success) {
        emit(const UserSyncSuccess());
        
        // Refresh the list to reflect synced changes
        add(const FetchUserList(page: 1, forceRefresh: true));
      } else {
        emit(const UserSyncError(message: 'Failed to sync changes'));
      }
    } catch (e) {
      emit(UserSyncError(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshUserData(
    RefreshUserData event,
    Emitter<UserState> emit,
  ) async {
    _currentPage = 1;
    _hasReachedMax = false;
    _currentUsers = [];
    add(const FetchUserList(page: 1, forceRefresh: true));
  }
  
  @override
  Future<void> close() {
    _userRepository.dispose();
    return super.close();
  }
}