# Fix Google Sign-In Error 401: invalid_client

## The Problem
You're seeing: **"Error 401: invalid_client"** and **"The OAuth client was not found"**

This means the Google OAuth client ID is either:
- Not set (still using placeholder)
- Incorrect
- Not created in Google Cloud Console

## Solution: Create and Configure OAuth Client ID

### Step 1: Create OAuth Client in Google Cloud Console

1. **Go to Google Cloud Console**:
   - Open: https://console.cloud.google.com/apis/credentials?project=my-flutter-apps-f87ea

2. **Create OAuth 2.0 Client ID**:
   - Click **"+ CREATE CREDENTIALS"** at the top
   - Select **"OAuth client ID"**

3. **If prompted to configure OAuth consent screen**:
   - Click **"Configure Consent Screen"**
   - Choose **"External"** (unless you have a Google Workspace)
   - Fill in:
     - App name: "Design System Builder"
     - User support email: Your email
     - Developer contact: Your email
   - Click **"Save and Continue"** through the steps
   - Go back to **Credentials** tab

4. **Create the Client**:
   - Application type: **"Web application"**
   - Name: **"Design System Builder Web"**
   - **Authorized JavaScript origins**:
     - `http://localhost`
     - `http://localhost:8080`
     - `http://localhost:5000`
     - `http://127.0.0.1`
     - `http://127.0.0.1:8080`
     - (Add your production domain when deploying)
   - **Authorized redirect URIs**:
     - `http://localhost`
     - `http://localhost:8080`
     - (Add your production redirect URI when deploying)
   - Click **"Create"**

5. **Copy the Client ID**:
   - You'll see a popup with your **Client ID**
   - It looks like: `47033728900-xxxxxxxxxxxxx.apps.googleusercontent.com`
   - **Copy this entire string**

### Step 2: Update web/index.html

1. **Open** `web/index.html`

2. **Find line 43**:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```

3. **Replace** `YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` with your actual Client ID:
   ```html
   <meta name="google-signin-client_id" content="47033728900-xxxxxxxxxxxxx.apps.googleusercontent.com">
   ```
   (Use the actual Client ID you copied from Step 1)

4. **Save the file**

### Step 3: Enable Google Sign-In in Firebase

1. **Go to Firebase Console**:
   - Open: https://console.firebase.google.com/project/my-flutter-apps-f87ea/authentication/providers

2. **Enable Google Sign-In**:
   - Click on **"Google"** provider
   - Toggle **"Enable"** to ON
   - Make sure the **Web client ID** matches the one you created (or leave it to auto-detect)
   - Click **"Save"**

### Step 4: Restart Your App

```bash
flutter run -d chrome
```

## Alternative: Add Client ID in Code

If the meta tag doesn't work, you can also add it directly in code:

1. **Open** `lib/providers/user_provider.dart`

2. **Find line 116** (GoogleSignIn initialization)

3. **Uncomment and update**:
   ```dart
   final GoogleSignIn googleSignIn = GoogleSignIn(
     scopes: ['email', 'profile'],
     clientId: '47033728900-xxxxxxxxxxxxx.apps.googleusercontent.com', // Your actual Client ID
   );
   ```

## Verify It's Working

After completing the steps:
1. Restart your app
2. Click "Sign in with Google"
3. You should see the Google sign-in popup (not an error)
4. After signing in, you'll be redirected back to your app

## Troubleshooting

### Still getting "invalid_client" error?

1. **Check the Client ID**:
   - Make sure there are no extra spaces
   - Make sure it's the full ID including `.apps.googleusercontent.com`

2. **Check Authorized Origins**:
   - Make sure `http://localhost` is in the authorized JavaScript origins
   - Check the exact port you're using (e.g., `http://localhost:8080`)

3. **Clear Browser Cache**:
   - Clear browser cache and cookies
   - Try in an incognito/private window

4. **Check Browser Console**:
   - Press F12 → Console tab
   - Look for any additional error messages

### Can't find the Client ID in Firebase Console?

The Client ID might not be automatically created. You need to create it manually in Google Cloud Console (Step 1 above).

## Quick Reference

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials?project=my-flutter-apps-f87ea
- **Firebase Console**: https://console.firebase.google.com/project/my-flutter-apps-f87ea/authentication/providers
- **Project ID**: my-flutter-apps-f87ea
- **Project Number**: 47033728900
