/// OAuth 2.0 **Web application** client (Google Cloud Console → APIs & Services → Credentials).
/// Required for Google Sign-In on **Windows** and **Linux** (the official `google_sign_in` plugin
/// does not support those platforms).
///
/// 1. Open the same GCP project as Firebase.
/// 2. Create OAuth client type **Web application**.
/// 3. Under **Authorized redirect URIs**, add: `http://localhost:8000` (default port; must match
///    [GoogleSignInParams.redirectPort] if you change it).
/// 4. Build or run with:
///    `flutter run -d windows --dart-define=GOOGLE_OAUTH_CLIENT_ID=YOUR_ID.apps.googleusercontent.com --dart-define=GOOGLE_OAUTH_CLIENT_SECRET=YOUR_SECRET`
///
/// The client secret is not a true secret for public desktop apps; Google documents this for
/// installed OAuth clients.
class GoogleOAuthDesktopConfig {
  GoogleOAuthDesktopConfig._();

  static const String clientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID',
    defaultValue: '',
  );

  static const String clientSecret = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_SECRET',
    defaultValue: '',
  );

  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty;
}

/// Thrown when the user taps Google Sign-In on Windows/Linux but desktop OAuth env vars are missing.
class GoogleSignInDesktopNotConfigured implements Exception {
  @override
  String toString() =>
      'Google Sign-In on Windows needs Web OAuth credentials. '
      'Create a Web application OAuth client in Google Cloud Console (same project as Firebase), '
      'add redirect URI http://localhost:8000, then run:\n'
      'flutter run -d windows '
      '--dart-define=GOOGLE_OAUTH_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com '
      '--dart-define=GOOGLE_OAUTH_CLIENT_SECRET=YOUR_CLIENT_SECRET\n'
      'See lib/config/google_oauth_desktop.dart';
}
