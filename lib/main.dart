import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/design_system_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const DesignSystemApp());
}

class DesignSystemApp extends StatelessWidget {
  const DesignSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DesignSystemProvider(),
      child: MaterialApp(
        title: 'Design System Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<DesignSystemProvider>(
          builder: (context, provider, _) {
            return provider.hasProject
                ? const DashboardScreen()
                : const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
