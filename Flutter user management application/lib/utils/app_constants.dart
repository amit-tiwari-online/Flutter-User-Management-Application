import 'dart:io';

class AppConstants {
  // API constants
  static const String baseApiUrl = 'https://c43d9c37-22a2-4d9b-9f13-923d980cd6ec.mock.pstmn.io';
  static const Duration apiTimeout = Duration(seconds: 10);
  
  // Hive box names
  static const String userBoxName = 'users';
  static const String settingsBoxName = 'settings';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int searchPageSize = 20;
  
  // Search
  static const Duration searchDebounce = Duration(milliseconds: 500);
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again later.';
  static const String noInternetErrorMessage = 'No internet connection. Please check your network and try again.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String notFoundErrorMessage = 'User not found.';
  static const String unauthorizedErrorMessage = 'Unauthorized access. Please login again.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  
  // Cache durations
  static const Duration cacheMaxAge = Duration(hours: 24);
  
  // App settings
  static const String appName = 'User Management';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String homeRoute = '/';
  static const String userDetailsRoute = '/user/:id';
  static const String addUserRoute = '/add-user';
  static const String editUserRoute = '/edit-user/:id';
  
  // Mock API fallback
  static bool get shouldUseMockData => false;
}