import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/utils/app_constants.dart';
import 'dart:async';

// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message ${statusCode != null ? '(Status code: $statusCode)' : ''}';
}

// API Provider
class ApiProvider {
  final http.Client _client;

  ApiProvider({http.Client? client}) : _client = client ?? http.Client();

  // Base HTTP request handler
  Future<Map<String, dynamic>> _request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('${AppConstants.baseApiUrl}$endpoint').replace(
      queryParameters: queryParams,
    );

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: _headers()).timeout(AppConstants.apiTimeout);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: _headers(),
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.apiTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: _headers(),
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.apiTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: _headers()).timeout(AppConstants.apiTimeout);
          break;
        default:
          throw ApiException(message: 'Unsupported method: $method');
      }

      // Check for HTTP error codes
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMessage;
        try {
          final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorJson['message']?.toString() ?? 'Unknown error occurred';
        } catch (e) {
          errorMessage = 'Server returned status code ${response.statusCode}';
        }
        throw ApiException(message: errorMessage, statusCode: response.statusCode);
      }

      if (response.body.isNotEmpty) {
        try {
          final result = jsonDecode(response.body);
          if (result is Map<String, dynamic>) {
            return result;
          } else {
            throw ApiException(message: 'Invalid response format');
          }
        } catch (e) {
          throw ApiException(message: 'Failed to parse response: $e');
        }
      }

      return {};
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } on TimeoutException {
      throw ApiException(message: 'Request timeout');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // GET paginated users
  Future<List<User>> getUsers({required int page, int limit = 10}) async {
    final response = await _request(
      endpoint: '/users',
      method: 'GET',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  }

  // GET user by ID
  Future<User> getUserById(int id) async {
    final response = await _request(
      endpoint: '/users/$id',
      method: 'GET',
    );

    return User.fromJson(response);
  }

  // POST create user
  Future<User> createUser(User user) async {
    final response = await _request(
      endpoint: '/users',
      method: 'POST',
      body: user.toJson(),
    );

    return User.fromJson(response);
  }

  // PUT update user
  Future<User> updateUser(User user) async {
    final response = await _request(
      endpoint: '/users/${user.id}',
      method: 'PUT',
      body: user.toJson(),
    );

    return User.fromJson(response);
  }

  // DELETE user
  Future<void> deleteUser(int id) async {
    await _request(
      endpoint: '/users/$id',
      method: 'DELETE',
    );
  }

  // GET search users by name or email
  Future<List<User>> searchUsers(String query) async {
    final response = await _request(
      endpoint: '/users',
      method: 'GET',
      queryParams: {'q': query},
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Common headers
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
  };

  // Close client
  void dispose() {
    _client.close();
  }
}
