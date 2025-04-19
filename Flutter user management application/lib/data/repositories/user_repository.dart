import 'dart:io';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/data/providers/api_provider.dart';
import 'package:flutter_user_management/data/providers/local_storage_provider.dart';
import 'package:flutter_user_management/utils/app_constants.dart';

class UserRepositoryException implements Exception {
  final String message;
  final bool isNetworkError;
  
  UserRepositoryException({
    required this.message,
    this.isNetworkError = false,
  });
  
  @override
  String toString() => 'UserRepositoryException: $message';
}

class UserRepository {
  final ApiProvider _apiProvider;
  final LocalStorageProvider _localStorageProvider;
  
  UserRepository({
    ApiProvider? apiProvider,
    LocalStorageProvider? localStorageProvider,
  }) : 
    _apiProvider = apiProvider ?? ApiProvider(),
    _localStorageProvider = localStorageProvider ?? LocalStorageProvider();
  
  Future<void> _initStorage() async {
    await _localStorageProvider.init();
  }
  
  // Get users with pagination support
  Future<List<User>> getUsers({
    required int page,
    int limit = AppConstants.defaultPageSize,
    bool forceRefresh = false,
  }) async {
    await _initStorage();
    
    try {
      // Check if we need fresh data
      final shouldUseCache = !forceRefresh && 
                            await _localStorageProvider.isCacheValid();
      
      if (shouldUseCache) {
        // Try to get data from local cache first
        final localUsers = await _localStorageProvider.getUsers(
          page: page,
          limit: limit,
        );
        
        if (localUsers.isNotEmpty) {
          return localUsers;
        }
      }
      
      // If cache is invalid or empty, fetch from API
      final apiUsers = await _apiProvider.getUsers(page: page, limit: limit);
      
      // Save to local storage
      if (apiUsers.isNotEmpty) {
        await _localStorageProvider.saveUsers(apiUsers);
        await _localStorageProvider.updateLastSyncTime();
      }
      
      return apiUsers;
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // If network error, try to get from cache even if it's stale
        try {
          final localUsers = await _localStorageProvider.getUsers(
            page: page,
            limit: limit,
          );
          
          if (localUsers.isNotEmpty) {
            return localUsers;
          }
        } catch (_) {
          // If cache also fails, throw the original network error
        }
        
        throw UserRepositoryException(
          message: AppConstants.noInternetErrorMessage,
          isNetworkError: true,
        );
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Get user by ID
  Future<User> getUserById(int id) async {
    await _initStorage();
    
    try {
      // Try to get from cache first
      final localUser = await _localStorageProvider.getUserById(id);
      
      if (localUser != null) {
        return localUser;
      }
      
      // If not in cache, get from API
      final apiUser = await _apiProvider.getUserById(id);
      
      // Save to cache
      await _localStorageProvider.saveUser(apiUser);
      
      return apiUser;
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // Try once more from cache
        final localUser = await _localStorageProvider.getUserById(id);
        
        if (localUser != null) {
          return localUser;
        }
        
        throw UserRepositoryException(
          message: AppConstants.noInternetErrorMessage,
          isNetworkError: true,
        );
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Create a new user
  Future<User> createUser(User user) async {
    await _initStorage();
    
    try {
      // Create user via API
      final createdUser = await _apiProvider.createUser(user);
      
      // Save to local storage
      await _localStorageProvider.saveUser(createdUser);
      
      return createdUser;
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // Handle offline case - create a local user with temporary ID
        // We'll use a negative ID to indicate it's local
        final localId = DateTime.now().millisecondsSinceEpoch * -1;
        final localUser = user.copyWith(
          id: localId,
          isLocal: true,
        );
        
        await _localStorageProvider.saveUser(localUser);
        
        return localUser;
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Update an existing user
  Future<User> updateUser(User user) async {
    await _initStorage();
    
    try {
      // If it's a local-only user (with negative ID)
      if (user.isLocal) {
        // Just update in local storage
        await _localStorageProvider.saveUser(user);
        return user;
      }
      
      // Otherwise, update via API
      final updatedUser = await _apiProvider.updateUser(user);
      
      // Save to local storage
      await _localStorageProvider.saveUser(updatedUser);
      
      return updatedUser;
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // If offline, update locally with isLocal flag
        final localUser = user.copyWith(isLocal: true);
        await _localStorageProvider.saveUser(localUser);
        
        return localUser;
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Delete a user
  Future<void> deleteUser(int id) async {
    await _initStorage();
    
    try {
      // If it's a local-only user (with negative ID)
      if (id < 0) {
        // Just delete from local storage
        await _localStorageProvider.deleteUser(id);
        return;
      }
      
      // Otherwise, delete from API
      await _apiProvider.deleteUser(id);
      
      // Delete from local storage too
      await _localStorageProvider.deleteUser(id);
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // If offline, we still delete it locally
        await _localStorageProvider.deleteUser(id);
        return;
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Search users
  Future<List<User>> searchUsers(String query) async {
    await _initStorage();
    
    try {
      // Try API search first
      final apiResults = await _apiProvider.searchUsers(query);
      
      // Also search local storage
      final localResults = await _localStorageProvider.searchUsers(query);
      
      // Combine results, giving preference to API results for duplicates
      final apiUserIds = apiResults.map((u) => u.id).toSet();
      final uniqueLocalResults = localResults.where(
        (user) => !apiUserIds.contains(user.id)
      ).toList();
      
      return [...apiResults, ...uniqueLocalResults];
    } on ApiException catch (e) {
      if (e.message.contains('No internet connection') || 
          e.message.contains('Failed to connect') ||
          e.message.contains('Connection refused')) {
        
        // If offline, just search locally
        return await _localStorageProvider.searchUsers(query);
      }
      
      throw UserRepositoryException(message: e.message);
    } catch (e) {
      throw UserRepositoryException(message: e.toString());
    }
  }
  
  // Clear local cache
  Future<void> clearCache() async {
    await _initStorage();
    await _localStorageProvider.clearUsers();
  }
  
  // Sync local data with remote
  Future<bool> syncLocalChanges() async {
    await _initStorage();
    
    try {
      final allUsers = await _localStorageProvider.getUsers();
      
      // Find local users that need syncing
      final localUsers = allUsers.where((user) => user.isLocal).toList();
      
      if (localUsers.isEmpty) {
        return true; // Nothing to sync
      }
      
      // Process each local user
      for (final localUser in localUsers) {
        try {
          if (localUser.id < 0) {
            // Local-only user (negative ID), create on server
            final createdUser = await _apiProvider.createUser(localUser);
            
            // Delete local version and save server version
            await _localStorageProvider.deleteUser(localUser.id);
            await _localStorageProvider.saveUser(createdUser);
          } else {
            // Existing user that was modified locally
            final updatedUser = await _apiProvider.updateUser(localUser);
            
            // Update with non-local version from server
            await _localStorageProvider.saveUser(updatedUser);
          }
        } catch (e) {
          // Skip this user and continue with others
          continue;
        }
      }
      
      await _localStorageProvider.updateLastSyncTime();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Dispose of resources
  void dispose() {
    _apiProvider.dispose();
  }
}