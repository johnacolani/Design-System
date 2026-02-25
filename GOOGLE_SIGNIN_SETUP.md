# Google Sign-In Web Setup Guide

## Problem
When trying to sign in with Google on web, you get this error:
```
ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, or pass clientId when initializing GoogleSignIn
```

## Solution

### Step 1: Get Your Web Client ID from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **my-flutter-apps-f87ea**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Under **Web SDK configuration**, you'll see:
   - **Web client ID**: `47033728900-xxxxx.apps.googleusercontent.com`
   - Copy this client ID

### Step 2: Add Client ID to HTML File

Open `web/index.html` and find this line:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

Replace `YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` with your actual client ID from Step 1.

For example:
```html
<meta name="google-signin-client_id" content="47033728900-abc123def456.apps.googleusercontent.com">
```

### Step 3: Alternative - Add Client ID in Code

If the meta tag doesn't work, you can also add it directly in the code:

1. Open `lib/providers/user_provider.dart`
2. Find the `GoogleSignIn` initialization (around line 101)
3. Uncomment and update the `clientId` parameter:

```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: '47033728900-xxxxx.apps.googleusercontent.com', // Your actual client ID
);
```

### Step 4: Verify Google Sign-In is Enabled

Make sure Google Sign-In is enabled in Firebase Console:
1. Go to **Authentication** → **Sign-in method**
2. Find **Google** in the list
3. Click on it and make sure it's **Enabled**
4. Click **Save**

### Step 5: Test

1. Restart your app: `flutter run -d chrome`
2. Try signing in with Google
3. It should work now!

## Troubleshooting

### Still not working?

1. **Check browser console** (F12) for any errors
2. **Verify the client ID** is correct (no typos)
3. **Clear browser cache** and try again
4. **Check authorized domains** in Google Cloud Console:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Select your project
   - Go to **APIs & Services** → **Credentials**
   - Find your OAuth 2.0 Client ID
   - Make sure your domain is in **Authorized JavaScript origins**

### Common Issues

- **"redirect_uri_mismatch"**: Add your domain to authorized origins in Google Cloud Console
- **"invalid_client"**: Check that the client ID is correct
- **"access_denied"**: Make sure Google Sign-In is enabled in Firebase Console

## Need Help?

If you're still having issues:
1. Check the browser console (F12) for detailed error messages
2. Verify all steps above are completed
3. Make sure you're using the correct Firebase project
