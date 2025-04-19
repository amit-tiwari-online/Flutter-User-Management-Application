import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/utils/app_constants.dart';

class LocalStorageException implements Exception {
  final String message;
  
  LocalStorageException(this.message);
  
  @override
  String toString() => 'LocalStorageException: $message';
}

class LocalStorageProvider {
  static const String _usersBoxName = AppConstants.userBoxName;
  static const String _settingsBoxName = AppConstants.settingsBoxName;
  static const String _lastSyncKey = 'last_sync_time';
  
  // Singleton instance
  static final LocalStorageProvider _instance = LocalStorageProvider._internal();
  
  factory LocalStorageProvider() => _instance;
  
  LocalStorageProvider._internal();
  
  bool _isInitialized = false;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);
      
      // Register adapters
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(CompanyAdapter());
      Hive.registerAdapter(GeoAdapter());
      
      // Open boxes
      await Hive.openBox<User>(_usersBoxName);
      await Hive.openBox<dynamic>(_settingsBoxName);
      
      _isInitialized = true;
    } catch (e) {
      throw LocalStorageException('Failed to initialize local storage: $e');
    }
  }
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }
  
  // User operations
  Future<List<User>> getUsers({int? page, int? limit}) async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      final allUsers = usersBox.values.toList();
      
      // Sort by ID
      allUsers.sort((a, b) => a.id.compareTo(b.id));
      
      // Apply pagination if specified
      if (page != null && limit != null) {
        final start = (page - 1) * limit;
        final end = start + limit;
        
        if (start >= allUsers.length) {
          return [];
        }
        
        return allUsers.sublist(start, end > allUsers.length ? allUsers.length : end);
      }
      
      return allUsers;
    } catch (e) {
      throw LocalStorageException('Failed to get users: $e');
    }
  }
  
  Future<User?> getUserById(int id) async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      
      // Find user by ID
      for (final user in usersBox.values) {
        if (user.id == id) {
          return user;
        }
      }
      
      return null;
    } catch (e) {
      throw LocalStorageException('Failed to get user by ID: $e');
    }
  }
  
  Future<void> saveUser(User user) async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      
      // Find existing user by ID to update or add as new
      int? existingKey;
      for (final entry in usersBox.toMap().entries) {
        if (entry.value.id == user.id) {
          existingKey = entry.key as int?;
          break;
        }
      }
      
      if (existingKey != null) {
        await usersBox.put(existingKey, user);
      } else {
        await usersBox.add(user);
      }
    } catch (e) {
      throw LocalStorageException('Failed to save user: $e');
    }
  }
  
  Future<void> saveUsers(List<User> users) async {
    await _ensureInitialized();
    
    try {
      for (final user in users) {
        await saveUser(user);
      }
    } catch (e) {
      throw LocalStorageException('Failed to save users batch: $e');
    }
  }
  
  Future<void> deleteUser(int id) async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      
      // Find the key for the user with the given ID
      int? keyToDelete;
      for (final entry in usersBox.toMap().entries) {
        if (entry.value.id == id) {
          keyToDelete = entry.key as int?;
          break;
        }
      }
      
      if (keyToDelete != null) {
        await usersBox.delete(keyToDelete);
      }
    } catch (e) {
      throw LocalStorageException('Failed to delete user: $e');
    }
  }
  
  Future<void> clearUsers() async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      await usersBox.clear();
    } catch (e) {
      throw LocalStorageException('Failed to clear users: $e');
    }
  }
  
  Future<List<User>> searchUsers(String query) async {
    await _ensureInitialized();
    
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      final allUsers = usersBox.values.toList();
      
      // Filter users by name or email
      final lowercaseQuery = query.toLowerCase();
      return allUsers.where((user) => 
        user.name.toLowerCase().contains(lowercaseQuery) || 
        user.email.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      throw LocalStorageException('Failed to search users: $e');
    }
  }
  
  // Sync time operations
  Future<DateTime?> getLastSyncTime() async {
    await _ensureInitialized();
    
    try {
      final settingsBox = Hive.box<dynamic>(_settingsBoxName);
      final timestamp = settingsBox.get(_lastSyncKey) as int?;
      
      return timestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(timestamp) 
          : null;
    } catch (e) {
      throw LocalStorageException('Failed to get last sync time: $e');
    }
  }
  
  Future<void> updateLastSyncTime() async {
    await _ensureInitialized();
    
    try {
      final settingsBox = Hive.box<dynamic>(_settingsBoxName);
      final now = DateTime.now().millisecondsSinceEpoch;
      await settingsBox.put(_lastSyncKey, now);
    } catch (e) {
      throw LocalStorageException('Failed to update last sync time: $e');
    }
  }
  
  Future<bool> isCacheValid() async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) {
        return false;
      }
      
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      
      return difference < AppConstants.cacheMaxAge;
    } catch (e) {
      return false;
    }
  }
  
  // Close all boxes
  Future<void> close() async {
    if (!_isInitialized) return;
    
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e) {
      throw LocalStorageException('Failed to close Hive: $e');
    }
  }
}