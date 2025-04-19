import 'package:equatable/equatable.dart';
import 'package:flutter_user_management/data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class UserInitial extends UserState {
  const UserInitial();
}

// Loading states
class UserListLoading extends UserState {
  const UserListLoading();
}

class UserDetailsLoading extends UserState {
  const UserDetailsLoading();
}

class UserLoadingMore extends UserState {
  final List<User> currentUsers;
  
  const UserLoadingMore({required this.currentUsers});
  
  @override
  List<Object?> get props => [currentUsers];
}

class UserActionLoading extends UserState {
  final UserState previousState;
  
  const UserActionLoading({required this.previousState});
  
  @override
  List<Object?> get props => [previousState];
}

// Success states
class UserListLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax;
  final int currentPage;
  final String? searchQuery;
  
  const UserListLoaded({
    required this.users,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.searchQuery,
  });
  
  UserListLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    int? currentPage,
    String? searchQuery,
  }) {
    return UserListLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [users, hasReachedMax, currentPage, searchQuery];
}

class UserDetailsLoaded extends UserState {
  final User user;
  
  const UserDetailsLoaded({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class UserAddSuccess extends UserState {
  final User user;
  
  const UserAddSuccess({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class UserUpdateSuccess extends UserState {
  final User user;
  
  const UserUpdateSuccess({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class UserDeleteSuccess extends UserState {
  final int userId;
  
  const UserDeleteSuccess({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

class UserSyncSuccess extends UserState {
  const UserSyncSuccess();
}

// Error states
class UserListError extends UserState {
  final String message;
  final bool isNetworkError;
  
  const UserListError({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  List<Object?> get props => [message, isNetworkError];
}

class UserDetailsError extends UserState {
  final String message;
  final bool isNetworkError;
  
  const UserDetailsError({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  List<Object?> get props => [message, isNetworkError];
}

class UserAddError extends UserState {
  final String message;
  final bool isNetworkError;
  
  const UserAddError({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  List<Object?> get props => [message, isNetworkError];
}

class UserUpdateError extends UserState {
  final String message;
  final bool isNetworkError;
  
  const UserUpdateError({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  List<Object?> get props => [message, isNetworkError];
}

class UserDeleteError extends UserState {
  final String message;
  final bool isNetworkError;
  
  const UserDeleteError({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  List<Object?> get props => [message, isNetworkError];
}

class UserSyncError extends UserState {
  final String message;
  
  const UserSyncError({required this.message});
  
  @override
  List<Object?> get props => [message];
}