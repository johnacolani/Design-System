import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/design_system_provider.dart';
import 'providers/user_provider.dart';
import 'providers/tokens_provider.dart';
import 'providers/billing_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TokensProvider()),
        ChangeNotifierProvider(create: (_) => BillingProvider()),
      ],
      child: MaterialApp(
        title: 'Design System Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5E5CE6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        home: Consumer2<UserProvider, BillingProvider>(
          builder: (context, userProvider, billingProvider, _) {
            if (userProvider.currentUser == null) {
              userProvider.initialize();
            }
            // Sync billing when user is logged in (non-guest)
            final uid = userProvider.currentUser?.id;
            if (uid != null && !uid.startsWith('guest_')) {
              billingProvider.watchBilling(uid);
            } else {
              billingProvider.stopWatching();
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
