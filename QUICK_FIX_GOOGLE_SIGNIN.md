# Quick Fix for Google Sign-In Error

## The Error
```
ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, or pass clientId when initializing GoogleSignIn
```

## Solution (Choose One)

### Option 1: Add Client ID to HTML (Recommended)

1. **Get your Web Client ID**:
   - Go to: https://console.firebase.google.com/project/my-flutter-apps-f87ea/authentication/providers
   - Click on **Google** provider
   - Under **Web SDK configuration**, copy the **Web client ID**
   - It looks like: `47033728900-xxxxx.apps.googleusercontent.com`

2. **Update `web/index.html`**:
   - Open `web/index.html`
   - Find line 43: `<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">`
   - Replace `YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` with your actual client ID
   - Example: `<meta name="google-signin-client_id" content="47033728900-abc123def456.apps.googleusercontent.com">`

3. **Restart the app**:
   ```bash
   flutter run -d chrome
   ```

### Option 2: Add Client ID in Code

1. **Get your Web Client ID** (same as Option 1, Step 1)

2. **Update `lib/providers/user_provider.dart`**:
   - Open `lib/providers/user_provider.dart`
   - Find the `GoogleSignIn` initialization (around line 159)
   - Uncomment and update the `clientId` parameter:
   ```dart
   final GoogleSignIn googleSignIn = GoogleSignIn(
     scopes: ['email', 'profile'],
     clientId: '47033728900-xxxxx.apps.googleusercontent.com', // Your actual client ID
   );
   ```

3. **Restart the app**

## Still Not Working?

1. **Check browser console** (F12) for detailed errors
2. **Verify Google Sign-In is enabled** in Firebase Console:
   - Authentication > Sign-in method > Google > Enabled
3. **Check authorized domains** in Google Cloud Console:
   - Go to: https://console.cloud.google.com/apis/credentials
   - Find your OAuth 2.0 Client ID
   - Make sure `localhost` and your domain are in **Authorized JavaScript origins**

## Need Help Finding Your Client ID?

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: **my-flutter-apps-f87ea**
3. Click **Authentication** → **Sign-in method**
4. Click **Google**
5. Scroll down to **Web SDK configuration**
6. Copy the **Web client ID**
