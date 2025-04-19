import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/presentation/screens/home_screen.dart';
import 'package:flutter_user_management/presentation/screens/user_details_screen.dart';
import 'package:flutter_user_management/presentation/screens/add_user_screen.dart';
import 'package:flutter_user_management/presentation/screens/edit_user_screen.dart';
import 'package:flutter_user_management/presentation/screens/error_screen.dart';
import 'package:flutter_user_management/utils/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    errorBuilder: (context, state) => ErrorScreen(
      error: 'Page not found: ${state.uri.path}',
    ),
    routes: [
      // Home route - list of users
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // User details route
      GoRoute(
        path: AppConstants.userDetailsRoute,
        name: 'user-details',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['id']!);
          return UserDetailsScreen(userId: userId);
        },
      ),
      
      // Add user route
      GoRoute(
        path: AppConstants.addUserRoute,
        name: 'add-user',
        builder: (context, state) => const AddUserScreen(),
      ),
      
      // Edit user route
      GoRoute(
        path: AppConstants.editUserRoute,
        name: 'edit-user',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['id']!);
          final user = state.extra as User?;
          return EditUserScreen(
            userId: userId,
            initialUser: user,
          );
        },
      ),
    ],
  );
}