import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/design_system_provider.dart';
import 'providers/user_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase not configured yet - app will still run
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please run: flutterfire configure');
  }
  
  runApp(const DesignSystemApp());
}

class DesignSystemApp extends StatelessWidget {
  const DesignSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => DesignSystemProvider()),
      ],
      child: MaterialApp(
        title: 'Design System Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            // Initialize user if not already done
            if (userProvider.currentUser == null) {
              userProvider.initialize();
            }
            // Show home screen (it handles guest users)
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
