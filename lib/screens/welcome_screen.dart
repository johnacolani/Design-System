import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/hero_value_prop.dart';
import '../utils/platform_icons.dart';
import '../utils/responsive.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';

bool _useWideLayout(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return width >= 700;
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildBrandingPanel(BuildContext context, Responsive responsive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(size: 120),
            const SizedBox(height: 32),
            Text(
              'Design System Builder',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 28,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            HeroValueProp(
              textColor: Colors.white.withOpacity(0.95),
              fontSize: 18,
              isMobile: false,
              showAccentBar: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final useWideLayout = _useWideLayout(context);

    const double cardMaxWidth = 400;
    final optionsCard = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: cardMaxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
                      padding: EdgeInsets.all(responsive.isMobile ? 24 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Get Started',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Choose how you want to continue',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Continue as Guest
                          OutlinedButton.icon(
                            onPressed: () {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              userProvider.initialize(); // Set as guest
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                              );
                            },
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Continue as Guest'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300])),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Sign up with Email
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(isSignUp: true),
                                ),
                              );
                            },
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Sign up with Email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Sign in with Google
                          Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              return ElevatedButton.icon(
                                onPressed: userProvider.isLoading
                                    ? null
                                    : () async {
                                        try {
                                          await userProvider.signInWithGoogle();
                                          if (context.mounted && userProvider.isLoggedIn) {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) => const OnboardingScreen(),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            // User might have canceled, don't show error
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Sign in canceled or failed. Please try again.'),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Google Sign-In failed: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                icon: userProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.google,
                                        size: 20,
                                        color: Color(0xFF4285F4),
                                      ),
                                label: Text(userProvider.isLoading ? 'Signing in...' : 'Sign in with Google'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  elevation: 1,
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Sign in link
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(isSignUp: false),
                                ),
                              );
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  Theme.of(context).colorScheme.secondary,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: useWideLayout
              ? Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildBrandingPanel(context, responsive),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: optionsCard),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(responsive.isMobile ? 20 : 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        AppLogo(size: responsive.isMobile ? 80 : 100),
                        const SizedBox(height: 20),
                        Text(
                          'Design System Builder',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: responsive.isMobile ? 24 : 28,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        HeroValueProp(
                          textColor: Colors.white.withOpacity(0.95),
                          fontSize: responsive.isMobile ? 16 : 18,
                          isMobile: responsive.isMobile,
                          showAccentBar: false,
                        ),
                        SizedBox(height: responsive.isMobile ? 28 : 36),
                        optionsCard,
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(platformBackIcon),
                color: Colors.white,
                tooltip: 'Back to landing page',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
