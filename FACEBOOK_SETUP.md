# Facebook Authentication Setup Guide

This guide will help you set up Facebook authentication for your Flutter app.

## Prerequisites

1. A Facebook Developer account
2. A Facebook App created in the Facebook Developer Console
3. Firebase project with Authentication enabled

## Step 1: Create a Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click "Create App"
3. Choose "Consumer" as the app type
4. Fill in your app details
5. Add Facebook Login product to your app

## Step 2: Configure Facebook App Settings

### Basic Settings
1. In your Facebook App Dashboard, go to Settings > Basic
2. Note down your **App ID** and **App Secret**
3. Add your app domains and privacy policy URL

### Facebook Login Settings
1. Go to Facebook Login > Settings
2. Add your app's bundle ID (iOS) and package name (Android)
3. Add your OAuth redirect URIs

## Step 3: Update Configuration Files

### Android Configuration
1. Open `android/app/src/main/res/values/strings.xml`
2. Replace the placeholder values:
   ```xml
   <string name="facebook_app_id">YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
   ```

### iOS Configuration
1. Open `ios/Runner/Info.plist`
2. Replace the placeholder values:
   ```xml
   <key>FacebookAppID</key>
   <string>YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <key>FacebookClientToken</key>
   <string>YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
   ```
3. Update the URL scheme:
   ```xml
   <string>fbYOUR_ACTUAL_FACEBOOK_APP_ID</string>
   ```

## Step 4: Configure Firebase

1. Go to your Firebase Console
2. Navigate to Authentication > Sign-in method
3. Enable Facebook as a sign-in provider
4. Enter your Facebook App ID and App Secret
5. Save the configuration

## Step 5: Test the Implementation

1. Run `flutter pub get` to install dependencies
2. Build and run your app
3. Test the Facebook login button
4. Verify that users can sign in with Facebook

## Troubleshooting

### Common Issues:
1. **"Invalid key hash" error**: Add your app's key hash to Facebook App Settings
2. **"App not configured" error**: Ensure your Facebook App is properly configured
3. **"Invalid OAuth redirect URI"**: Check your redirect URIs in Facebook App Settings

### Getting Key Hash (Android):
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

### Getting Key Hash (iOS):
Use the Facebook SDK to log the key hash during development.

## Security Notes

- Never commit your actual Facebook App Secret to version control
- Use environment variables or secure storage for sensitive configuration
- Regularly rotate your app secrets
- Follow Facebook's data usage and privacy policies

## Additional Resources

- [Facebook Login Documentation](https://developers.facebook.com/docs/facebook-login/)
- [Flutter Facebook Auth Plugin](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth) 