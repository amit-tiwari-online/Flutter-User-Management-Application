import 'package:equatable/equatable.dart';
import 'package:flutter_user_management/data/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  
  @override
  List<Object?> get props => [];
}

// Fetch a paginated list of users
class FetchUserList extends UserEvent {
  final int page;
  final bool forceRefresh;
  
  const FetchUserList({
    required this.page,
    this.forceRefresh = false,
  });
  
  @override
  List<Object?> get props => [page, forceRefresh];
}

// Load more users (pagination)
class LoadMoreUsers extends UserEvent {
  const LoadMoreUsers();
}

// Fetch a specific user by ID
class FetchUserDetails extends UserEvent {
  final int userId;
  
  const FetchUserDetails({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

// Add a new user
class AddUser extends UserEvent {
  final User user;
  
  const AddUser({required this.user});
  
  @override
  List<Object?> get props => [user];
}

// Update an existing user
class UpdateUser extends UserEvent {
  final User user;
  
  const UpdateUser({required this.user});
  
  @override
  List<Object?> get props => [user];
}

// Delete a user
class DeleteUser extends UserEvent {
  final int userId;
  
  const DeleteUser({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

// Search for users by query
class SearchUsers extends UserEvent {
  final String query;
  
  const SearchUsers({required this.query});
  
  @override
  List<Object?> get props => [query];
}

// Clear search results and return to normal list
class ClearSearch extends UserEvent {
  const ClearSearch();
}

// Sync local changes with server
class SyncChanges extends UserEvent {
  const SyncChanges();
}

// Refresh all data
class RefreshUserData extends UserEvent {
  const RefreshUserData();
}