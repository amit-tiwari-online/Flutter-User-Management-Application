# Flutter User Management Application
A comprehensive Flutter-based user management application that allows users to view, add, edit, and delete user information. The application follows the BLoC pattern for state management and implements a responsive UI design with both online data fetching and offline caching functionality.
## 📱 Features
- **User List:** View all users with profile image, name, and basic details
- **User Details:** View full information for each user
- **Add New User:** Create new users with form validation
- **Edit User:** Update existing user information
- **Delete User:** Remove users from the system
- **Offline Support:** Cache data for offline access using Hive
- **Responsive UI:** Works on multiple screen sizes
- **Error Handling:** Graceful error management with retry options
- **Loading States:** Shimmer loading effects during data fetching
## 🛠️ Built With
- **Flutter:** SDK for building cross-platform applications
- **BLoC Pattern:** For state management
- **Hive:** For local data caching
- **Dio:** For API requests
- **Go Router:** For navigation
- **Form Validation:** For input validation
- **SVG Support:** For vector icons
## 📋 Prerequisites
Before running this project, make sure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.10.0 or higher)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
## 🚀 Getting Started
### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/amit-tiwari-online/Flutter-User-Management-Application.git
Navigate to the project folder:
![ChatGPT Image Apr 16, 2025, 07_37_40 PM](https://github.com/user-attachments/assets/0556b760-b62f-446f-933d-0fa5a570f4d8)



cd Flutter-User-Management-Application
Install dependencies:

flutter pub get
Generate the required code files:

flutter pub run build_runner build --delete-conflicting-outputs
Run the application:

flutter run
Running on Different Platforms
Android
flutter run -d android
iOS (requires macOS)
flutter run -d ios
Web
flutter run -d chrome
🏗️ Project Structure
![structure](https://github.com/user-attachments/assets/064c75ec-dc80-43ce-a1b3-4b9635b152c1)


🌐 API
The application connects to the JSONPlaceholder API for demonstration purposes. In a production environment, you would replace this with your actual API.

⚠️ Common Issues
Build Issues
If you encounter build errors:

flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
Hive Generator Issues
If Hive adapters are not generating properly:

flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
📱 Screenshots
<!-- Add your screenshots here -->
🧪 Running Tests
flutter test
🤝 Contributing
Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

👤 Author
Amit Tiwari - GitHub Profile

This README provides:
1. An overview of what the application does
2. Technologies used
3. Detailed installation instructions
4. How to run on different platforms
5. Project structure explanation
6. Troubleshooting common issues
7. How to contribute
8. License information and authorship
Feel free to customize it further with screenshots, additional details specific to your implementation, or any other information you think would be helpful for users.
The application fetches data from a remote API but also caches it locally, so you'll be able to browse users even when offline after the initial data load.

The UI follows Material Design guidelines and is responsive, so it will work on different screen sizes (phone, tablet, desktop if running on Flutter web).

When you run the application on your device or emulator with the commands I mentioned earlier, you'll immediately see the user interface with the list of users loaded from the API.
