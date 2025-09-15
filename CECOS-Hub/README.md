# CECOS Hub

A Flutter-based social media application for CECOS University students to share posts, interact with content, and stay connected with their peers.

## 📱 Features

- **User Authentication**: Firebase-based authentication with email/password
- **Real-time Posts**: Supabase-powered real-time post sharing and updates
- **Push Notifications**: FCM notifications for new posts and interactions
- **User Profiles**: Customizable user profiles with department and semester information
- **Media Support**: Image sharing capabilities
- **Real-time Updates**: Live updates when new posts are created

## 🏗️ Architecture & Flow

### Application Flow

```
1. App Launch
   ├── Initialize Firebase & Supabase
   ├── Initialize Notification Service
   ├── Check Authentication State
   └── Navigate to Login/Home Screen

2. Authentication Flow
   ├── Login Screen
   │   ├── Email/Password Validation
   │   ├── Firebase Authentication
   │   └── Load User Data from Firestore
   └── Sign Up Screen
       ├── User Registration
       ├── Profile Creation
       └── Firestore Document Creation

3. Main Application Flow
   ├── Home Screen
   │   ├── Load Posts (Supabase)
   │   ├── Real-time Post Updates
   │   ├── Create New Posts
   │   └── User Interactions
   └── Profile Management
       ├── Update Profile Information
       └── View User Statistics
```

### Data Flow

```
User Action → Service Layer → Database → Real-time Updates → UI Refresh
     ↓              ↓            ↓            ↓              ↓
  Create Post → SupabasePosts → Supabase → Real-time → Notification
  Service      Service         Database   Channel     Service
```

### Key Components

- **AuthService**: Handles Firebase authentication and user management
- **SupabasePostsService**: Manages posts CRUD operations and real-time subscriptions
- **NotificationService**: Handles FCM and local notifications
- **Models**: UserModel, PostModel for data structure

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project
- Supabase project

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/cecos_hub.git
cd cecos_hub
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Credentials

**⚠️ IMPORTANT**: All sensitive information has been replaced with placeholders. You must configure your own credentials before running the application.

#### 3.1 Firebase Setup

**Create Firebase Project:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create Firestore database
5. Enable Cloud Messaging

**Get Firebase Credentials:**
1. Go to **Project Settings** > **General**
2. Scroll down to **Your apps** section
3. Add apps for each platform (Android, iOS, Web, etc.)
4. Note down the following for each platform:
   - API Key
   - App ID
   - Messaging Sender ID
   - Client IDs (from Authentication settings)

**Update Firebase Configuration Files:**

**Update `lib/firebase_options.dart`:**
Replace the following placeholders:
- `YOUR_ANDROID_API_KEY` → Your Android API key
- `YOUR_IOS_API_KEY` → Your iOS API key
- `YOUR_WEB_API_KEY` → Your Web API key
- `YOUR_MACOS_API_KEY` → Your macOS API key
- `YOUR_WINDOWS_API_KEY` → Your Windows API key
- `YOUR_ANDROID_APP_ID` → Your Android App ID
- `YOUR_IOS_APP_ID` → Your iOS App ID
- `YOUR_WEB_APP_ID` → Your Web App ID
- `YOUR_MACOS_APP_ID` → Your macOS App ID
- `YOUR_WINDOWS_APP_ID` → Your Windows App ID
- `YOUR_MESSAGING_SENDER_ID` → Your Messaging Sender ID
- `YOUR_PROJECT_ID` → Your Firebase Project ID
- `YOUR_ANDROID_CLIENT_ID` → Your Android Client ID
- `YOUR_IOS_CLIENT_ID` → Your iOS Client ID
- `YOUR_IOS_BUNDLE_ID` → Your iOS Bundle ID
- `YOUR_MEASUREMENT_ID` → Your Web Measurement ID
- `YOUR_WINDOWS_MEASUREMENT_ID` → Your Windows Measurement ID

**Update `android/app/google-services.json`:**
Replace the following placeholders:
- `YOUR_PROJECT_NUMBER` → Your Firebase Project Number
- `YOUR_PROJECT_ID` → Your Firebase Project ID
- `YOUR_ANDROID_APP_ID` → Your Android App ID
- `YOUR_PACKAGE_NAME` → Your Android Package Name
- `YOUR_ANDROID_CLIENT_ID` → Your Android Client ID
- `YOUR_WEB_CLIENT_ID` → Your Web Client ID
- `YOUR_IOS_CLIENT_ID` → Your iOS Client ID
- `YOUR_IOS_BUNDLE_ID` → Your iOS Bundle ID
- `YOUR_ANDROID_API_KEY` → Your Android API Key
- `YOUR_CERTIFICATE_HASH` → Your Android Certificate Hash

**Update `firebase.json`:**
Replace the following placeholders:
- `YOUR_PROJECT_ID` → Your Firebase Project ID
- `YOUR_ANDROID_APP_ID` → Your Android App ID
- `YOUR_IOS_APP_ID` → Your iOS App ID
- `YOUR_MACOS_APP_ID` → Your macOS App ID
- `YOUR_WEB_APP_ID` → Your Web App ID
- `YOUR_WINDOWS_APP_ID` → Your Windows App ID

#### 3.2 Supabase Setup

**Create Supabase Project:**
1. Go to [Supabase](https://supabase.com/)
2. Create a new project
3. Wait for the project to be ready

**Get Supabase Credentials:**
1. Go to **Settings** > **API**
2. Copy the following:
   - Project URL
   - Anon (public) key

**Update Supabase Configuration:**

**Update `lib/main.dart`:**
Replace the following placeholders:
- `YOUR_SUPABASE_URL` → Your Supabase Project URL
- `YOUR_SUPABASE_ANON_KEY` → Your Supabase Anon Key

**Database Schema:**
Run the following SQL in your Supabase SQL Editor:

```sql
-- Posts table
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  description TEXT NOT NULL,
  mediaurl TEXT,
  createdby UUID NOT NULL,
  createdbyname TEXT NOT NULL,
  createdbyavatar TEXT,
  createdat TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  likes TEXT[] DEFAULT '{}',
  comments JSONB DEFAULT '[]'::jsonb
);

-- Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Posts are viewable by everyone" ON posts
  FOR SELECT USING (true);

-- Create policy for authenticated users to insert
CREATE POLICY "Authenticated users can insert posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Enable real-time for posts table
ALTER PUBLICATION supabase_realtime ADD TABLE posts;
```

#### 3.3 FCM Configuration (Optional)

**Get FCM Server Key:**
1. Go to Firebase Console > **Project Settings** > **Cloud Messaging**
2. Copy the Server Key

**Update FCM Configuration:**

**Update `lib/services/notification_service.dart`:**
Replace the following placeholder:
- `YOUR_FCM_SERVER_KEY` → Your FCM Server Key

**⚠️ Security Warning:** For production, never embed the FCM server key in the client. Use a backend service or Supabase Edge Function instead.

#### 3.4 Platform-Specific Setup

**Android Setup:**
1. Ensure `minSdkVersion` is at least 21 in `android/app/build.gradle`
2. Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.VIBRATE" />
```

**iOS Setup:**
1. Ensure iOS deployment target is 11.0 or higher
2. Add notification permissions in `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

#### 3.5 Environment Variables (Recommended)

For production deployment, consider using environment variables instead of hardcoding values:

1. **Use the environment template**: Copy `environment_template.txt` to `.env` and fill in your values
2. Use packages like `flutter_dotenv` to load environment variables
3. Never commit the `.env` file to version control

### 4. Run the Application

```bash
# Install dependencies
flutter pub get

# For development
flutter run

# For release build
flutter build apk --release
```

### 5. Verification

After setup, verify that:
1. ✅ Firebase authentication works
2. ✅ Supabase connection is established
3. ✅ Posts can be created and retrieved
4. ✅ Real-time updates work
5. ✅ Notifications are received (if FCM is configured)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── post_model.dart      # Post data structure
│   └── user_model.dart      # User data structure
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   └── home/                # Main app screens
├── services/                 # Business logic
│   ├── auth_service.dart    # Authentication service
│   ├── supabase_posts_service.dart # Posts management
│   └── notification_service.dart   # Notifications
└── utils/                    # Utilities
    └── app_colors.dart      # App color scheme
```

## 🔧 Configuration Files

- `pubspec.yaml` - Flutter dependencies
- `firebase.json` - Firebase configuration
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

## 🚨 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure all API keys and App IDs are correct
   - Run `flutter clean && flutter pub get`
   - Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations

2. **Supabase connection issues**
   - Verify URL and key in `main.dart`
   - Check RLS policies in Supabase dashboard
   - Ensure database schema is properly set up

3. **Notifications not working**
   - Ensure FCM is properly configured
   - Check device notification permissions
   - Verify FCM server key (if using direct FCM)

4. **Build errors**
   - Run `flutter clean`
   - Delete `pubspec.lock` and run `flutter pub get`
   - Check Flutter and Dart SDK versions

5. **Authentication issues**
   - Verify Firebase Authentication is enabled
   - Check email/password sign-in method is enabled
   - Ensure Firestore rules allow user document creation

6. **Real-time updates not working**
   - Check Supabase real-time is enabled
   - Verify RLS policies allow read access
   - Ensure proper subscription setup

### Debug Mode

The app includes debug logging that can be enabled by setting `kDebugMode` to true in the notification service.

### Support

If you encounter any issues during setup, please:
1. Check the troubleshooting section above
2. Verify all credentials are correctly placed
3. Ensure all required services are enabled in Firebase/Supabase
4. Check Flutter and Dart SDK versions compatibility

## 📝 Environment Variables

For production deployment, consider using environment variables for:

- Supabase URL and Key
- FCM Server Key
- Firebase configuration

## 🔒 Security

### Sensitive Information

All sensitive information has been replaced with placeholders for security:

- ✅ Firebase API keys and project IDs → Placeholders
- ✅ Supabase URL and API key → Placeholders  
- ✅ FCM server key → Placeholder
- ✅ Google Services configuration → Placeholders

### Security Best Practices

1. **Never commit sensitive keys** to version control
2. **Use environment variables** in production
3. **Consider using a backend service** for FCM instead of client-side keys
4. **Regularly rotate your API keys**
5. **Use Firebase App Check** for additional security
6. **Enable Row Level Security** in Supabase
7. **Use HTTPS** for all API communications
8. **Implement proper authentication flows**
9. **Validate all user inputs**
10. **Use secure storage for sensitive data**

### Setup Security

Before running the application:
1. Replace all placeholders with your actual credentials
2. Follow the security guidelines in this README
3. Never share your actual API keys or credentials
4. Use environment variables for production deployments
5. Regularly audit and rotate your API keys
6. Monitor your Firebase and Supabase usage for unusual activity

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
