# Flutter User Management Application

A comprehensive Flutter application for managing users with features like viewing, adding, editing, and deleting user information. The application follows the BLoC pattern for state management and implements both online and offline capabilities.

## Project Structure

```
lib/
├── bloc/                   # BLoC pattern implementation
│   ├── user_bloc.dart      # Main user bloc
│   ├── user_event.dart     # User events
│   └── user_state.dart     # User states
├── data/                   # Data layer
│   ├── models/             # Data models
│   ├── providers/          # Data providers (API, local storage)
│   └── repositories/       # Repositories (coordinate between providers)
├── presentation/           # UI layer
│   ├── screens/            # App screens
│   ├── widgets/            # Reusable UI components
│   └── routes/             # Navigation routes
├── utils/                  # Utility classes and helpers
└── main.dart               # Application entry point
```

## Features

- **User List Screen**: View all users with infinite scroll pagination
- **User Details Screen**: Detailed view of user information
- **Add User Screen**: Create new users
- **Edit User Screen**: Modify existing user information
- **Search Functionality**: Find users by name or email
- **Offline Support**: Cache data for offline access
- **Responsive Design**: Works on various screen sizes

## Architecture

This application follows the BLoC (Business Logic Component) pattern with a clean architecture approach:

- **Presentation Layer**: UI components that interact with the user
- **Business Logic Layer**: BLoCs that handle state management and business logic
- **Data Layer**: Repositories and providers that handle data operations

## Technologies Used

- Flutter for cross-platform UI development
- BLoC pattern for state management
- Hive for local storage and offline caching
- HTTP for API communication
- GoRouter for navigation

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run the application with `flutter run`

## API Integration

The application integrates with a RESTful API for user management operations and implements local caching for offline functionality.

## Credits

This project was created as part of a Flutter development assignment.