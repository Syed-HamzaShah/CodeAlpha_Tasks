# Fitness Tracker App

A comprehensive Flutter-based fitness tracking application that helps you monitor your daily workouts, track your progress, and achieve your fitness goals. Built with a modern Material Design 3 UI and powered by SQLite for local data storage.

## 📱 Features

### 🎯 Core Features
- **Activity Tracking**: Log various types of workouts including Running, Cycling, Yoga, Walking, Swimming, Weight Training, HIIT, Pilates, Dancing, and more
- **Step Counter Integration**: Automatically fetch step count from your device's pedometer for walking and running activities
- **Progress Dashboard**: View your fitness progress with beautiful charts and statistics for Daily, Weekly, and Monthly periods
- **Goal Setting**: Set and track customizable fitness goals for steps, calories, and workout duration (Daily, Weekly, Monthly)
- **Activity History**: Browse, filter, edit, and delete your past activities with advanced filtering options
- **Data Visualization**: Interactive bar charts showing calorie burn trends over time
- **Progress Tracking**: Monitor your progress towards goals with visual progress indicators

### 📊 Dashboard Features
- **Period Selection**: Switch between Daily, Weekly, and Monthly views
- **Progress Cards**: Visual cards showing:
  - Calories burned
  - Steps taken
  - Workout duration
  - Number of workouts
- **Activity Charts**: Bar charts displaying calorie burn patterns
- **Recent Activities**: Quick view of your latest 5 activities

### 🗂️ History Features
- **Advanced Filtering**: Filter activities by:
  - Time period (Today, This Week, This Month, All)
  - Exercise type
  - Specific date
- **Activity Management**: Edit or delete activities with a simple tap
- **Detailed Activity View**: View comprehensive details for each activity

### ⚙️ Settings Features
- **Customizable Goals**: Set personalized goals for:
  - Daily, Weekly, and Monthly step goals
  - Daily, Weekly, and Monthly calorie goals
  - Daily, Weekly, and Monthly workout duration goals
- **Persistent Storage**: Goals are saved locally and persist across app sessions

## 🛠️ Technologies Used

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Charts**: fl_chart
- **Step Counting**: pedometer
- **Permissions**: permission_handler
- **Local Storage**: shared_preferences
- **Date Formatting**: intl

## 📋 Requirements

- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Android device/emulator (Android 5.0+) or iOS device/simulator (iOS 12.0+)
- For step counting: Device with step counter support (most modern smartphones)

## 🚀 Installation

### Prerequisites

1. **Install Flutter**: Follow the official [Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### Setup Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd fitness_tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK version: 21 (Android 5.0)
- For step counting, the app requires `ACTIVITY_RECOGNITION` permission
- The permission is automatically requested when needed

#### iOS
- Minimum iOS version: 12.0
- For step counting, add the following to `Info.plist`:
  ```xml
  <key>NSMotionUsageDescription</key>
  <string>This app needs access to motion and fitness data to track your steps.</string>
  ```

## 📱 Usage

### Adding an Activity

1. Tap the **"Add Activity"** floating action button
2. Select an exercise type from the dropdown
3. Enter the duration (in minutes)
4. Enter calories burned
5. For walking/running activities, you can:
   - Manually enter steps, or
   - Tap "Get Steps from Device" to fetch from your device's pedometer
6. Select the date and time
7. Tap **"Add Activity"** to save

### Viewing Dashboard

1. Navigate to the **Dashboard** tab (default screen)
2. Select a period: **Daily**, **Weekly**, or **Monthly**
3. View your progress cards and charts
4. Pull down to refresh data

### Viewing History

1. Navigate to the **History** tab
2. Use the filter icon to filter activities by:
   - Time period
   - Exercise type
   - Specific date
3. Tap on an activity to edit it
4. Use the menu (three dots) to edit or delete activities

### Setting Goals

1. Navigate to the **Settings** tab
2. Enter your desired goals for:
   - Daily goals (steps, calories, workout duration)
   - Weekly goals (steps, calories, workout duration)
   - Monthly goals (steps, calories, workout duration)
3. Tap **"Save Goals"** to save your preferences

## 📁 Project Structure

```
lib/
├── database/
│   └── database_helper.dart      # SQLite database operations
├── models/
│   └── fitness_activity.dart     # Data models (FitnessActivity, FitnessGoals)
├── providers/
│   ├── fitness_provider.dart     # State management for activities
│   └── goals_provider.dart       # State management for goals
├── screens/
│   ├── splash_screen.dart        # Splash screen
│   ├── home_screen.dart          # Main navigation screen
│   ├── dashboard_screen.dart     # Dashboard with charts and progress
│   ├── history_screen.dart       # Activity history with filters
│   ├── add_activity_screen.dart  # Add/Edit activity screen
│   └── settings_screen.dart      # Settings and goals screen
├── services/
│   └── step_counter_service.dart # Step counter integration
└── main.dart                     # App entry point
```

## 🔐 Permissions

The app requires the following permissions:

- **Activity Recognition** (Android): Required for step counting
  - Automatically requested when you try to fetch steps from the device
  - You can deny this permission and manually enter steps instead

- **Motion & Fitness** (iOS): Required for step counting
  - Requested when you try to fetch steps from the device

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.1
  sqflite: ^2.3.0
  path: ^1.8.3
  fl_chart: ^0.65.0
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  pedometer: ^4.0.1
  permission_handler: ^11.3.0
```

## 🎨 UI/UX Features

- **Modern Material Design 3**: Beautiful, modern interface
- **Gradient Themes**: Eye-catching gradient colors throughout the app
- **Smooth Animations**: Fluid transitions and animations
- **Responsive Design**: Works on various screen sizes
- **Dark Mode Ready**: Built with Material 3 theming system
- **Intuitive Navigation**: Easy-to-use bottom navigation bar

## 🔧 Configuration

### Default Goals

The app comes with default goals that can be customized:
- **Daily**: 10,000 steps, 500 calories, 30 minutes
- **Weekly**: 70,000 steps, 3,500 calories, 210 minutes
- **Monthly**: 300,000 steps, 15,000 calories, 900 minutes

### Exercise Types

Supported exercise types:
- Running
- Cycling
- Yoga
- Walking
- Swimming
- Weight Training
- HIIT
- Pilates
- Dancing
- Other

## 🐛 Troubleshooting

### Step Counter Not Working

1. **Check Permissions**: Ensure activity recognition permission is granted
2. **Device Support**: Verify your device supports step counting
3. **Manual Entry**: You can always manually enter step counts

### Database Issues

1. **Clear App Data**: If you encounter database errors, try clearing app data
2. **Reinstall**: As a last resort, uninstall and reinstall the app

### Build Issues

1. **Clean Build**: Run `flutter clean` and then `flutter pub get`
2. **Update Dependencies**: Run `flutter pub upgrade`
3. **Check Flutter Version**: Ensure you're using Flutter 3.9.2 or higher

## 🚧 Future Enhancements

Potential features for future versions:
- Export data to CSV/JSON
- Integration with health apps (Google Fit, Apple Health)
- Social features (share achievements)
- Workout plans and recommendations
- Nutrition tracking
- Wearable device integration
- Cloud sync
- Dark mode support

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All the package maintainers whose work made this app possible
- The fitness community for inspiration

---

**Made with ❤️ using Flutter**
