import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_management/bloc/user_event.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_user_management/bloc/user_bloc.dart';
import 'package:flutter_user_management/data/models/user_model.dart';
import 'package:flutter_user_management/data/providers/local_storage_provider.dart';
import 'package:flutter_user_management/data/repositories/user_repository.dart';
import 'package:flutter_user_management/presentation/routes/app_router.dart';
import 'package:flutter_user_management/utils/app_constants.dart';
import 'package:flutter_user_management/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize local storage
  final localStorageProvider = LocalStorageProvider();
  await localStorageProvider.init();
  
  runApp(UserManagementApp(
    userRepository: UserRepository(
      localStorageProvider: localStorageProvider,
    ),
  ));
}

class UserManagementApp extends StatelessWidget {
  final UserRepository userRepository;
  
  const UserManagementApp({
    super.key,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(userRepository: userRepository)
        ..add(const FetchUserList(page: 1)),
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside of input fields
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && 
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}

// For testing and debugging
class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- ${bloc.runtimeType}');
  }
}