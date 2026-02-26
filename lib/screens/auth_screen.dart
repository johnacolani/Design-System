import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/user_provider.dart';
import '../utils/platform_icons.dart';
import '../widgets/app_logo.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

/// Returns a user-friendly message for auth errors.
String _authErrorMessage(Object e) {
  if (e is firebase_auth.FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return e.message ?? 'Sign in failed. Please try again.';
    }
  }
  return e.toString();
}

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  final String? preFilledEmail;
  final String? preFilledPassword;
  
  const AuthScreen({
    super.key,
    this.isSignUp = false,
    this.preFilledEmail,
    this.preFilledPassword,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isLogin = !widget.isSignUp;
    
    // Pre-fill email and password if provided (after signup)
    if (widget.preFilledEmail != null) {
      _emailController.text = widget.preFilledEmail!;
    }
    if (widget.preFilledPassword != null) {
      _passwordController.text = widget.preFilledPassword!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (_isLogin) {
        try {
          await userProvider.login(
            _emailController.text.trim(),
            _passwordController.text,
          );

          if (mounted && userProvider.isLoggedIn) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (mounted) {
            // Login didn't throw but we're not logged in (e.g. Firestore load failed)
            _showLoginError(context, 'Sign-in did not complete. Please try again.');
          }
        } catch (e, stackTrace) {
          debugPrint('Login error: $e');
          debugPrint(stackTrace.toString());
          if (mounted) {
            _showLoginError(context, _authErrorMessage(e));
          }
        }
      } else {
        // Sign up - save email and password for login screen
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final name = _nameController.text.trim();
        
        try {
          await userProvider.signUp(
            name,
            email,
            password,
          );

          if (mounted) {
            // Sign out so user can log in with pre-filled credentials
            await userProvider.logout();
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account created successfully! Please sign in.'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Navigate to login screen with pre-filled credentials
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AuthScreen(
                    isSignUp: false,
                    preFilledEmail: email,
                    preFilledPassword: password,
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            _showLoginError(
              context,
              _authErrorMessage(e),
              title: 'Sign up failed',
            );
          }
        }
      }
    }
  }

  /// Wide (split) layout on desktop platforms, or when viewport is wide (e.g. web).
  static bool _useWideLayout(BuildContext context) {
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

  void _showLoginError(BuildContext context, String message, {String? title}) {
    // Use a dialog so the error is impossible to miss (SnackBar can be hidden on desktop)
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'Sign in failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(size: 120),
            const SizedBox(height: 24),
            Text(
              'Design System Builder',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create and export design systems\nfor Flutter, Kotlin, and Swift',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            // Space for later: add more info here
          ],
        ),
      ),
    );
  }

  static const double _formCardMaxWidth = 400;

  Widget _buildFormCard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _formCardMaxWidth),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Sign in to continue'
                      : 'Start building your design systems',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            return ElevatedButton(
                              onPressed: userProvider.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: userProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
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
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            return ElevatedButton.icon(
                              onPressed: userProvider.isLoading
                                  ? null
                                  : () async {
                                      try {
                                        await userProvider.signInWithGoogle();
                                        if (mounted && userProvider.isLoggedIn) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                                          );
                                        } else if (mounted) {
                                          _showLoginError(
                                            context,
                                            'Sign in was canceled or did not complete.',
                                            title: 'Google Sign-In',
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint('Google Sign-In error: $e');
                                        if (mounted) {
                                          _showLoginError(
                                            context,
                                            e.toString(),
                                            title: 'Google Sign-In failed',
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
                              label: Text(
                                userProvider.isLoading ? 'Signing in...' : 'Sign in with Google',
                              ),
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Sign Up"
                                : 'Already have an account? Sign In',
                          ),
                        ),
                        const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Continue as guest
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
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
              ],
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useWideLayout = _useWideLayout(context);

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
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: useWideLayout
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildBrandingPanel(context),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: Center(child: _buildFormCard(context)),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBrandingPanel(context),
                            const SizedBox(height: 12),
                            Center(child: _buildFormCard(context)),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
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
