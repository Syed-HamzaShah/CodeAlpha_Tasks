import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterService {
  Stream<StepCount>? _stepCountStream;
  bool _isListening = false;

  int _currentStepCount = 0;
  DateTime? _lastStepCountUpdate;

  // Get current step count
  int get currentStepCount => _currentStepCount;
  DateTime? get lastUpdate => _lastStepCountUpdate;

  // Initialize step counting
  Future<bool> initialize() async {
    try {
      // Request permission first
      final permissionGranted = await requestPermission();
      if (!permissionGranted) {
        return false;
      }

      // Initialize pedometer
      _stepCountStream = Pedometer.stepCountStream;

      return true;
    } catch (e) {
      debugPrint('Error initializing step counter: $e');
      return false;
    }
  }

  // Request permission for step counting
  Future<bool> requestPermission() async {
    try {
      // Check if permission is already granted
      PermissionStatus status;

      // For Android, use ACTIVITY_RECOGNITION permission
      if (await Permission.activityRecognition.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.activityRecognition.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // User has permanently denied permission
        return false;
      } else {
        // Permission denied
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // Check if permission is granted
  Future<bool> isPermissionGranted() async {
    try {
      return await Permission.activityRecognition.isGranted;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  // Get steps for today
  Future<int> getTodaySteps() async {
    try {
      // Check if streams are initialized
      if (_stepCountStream == null) {
        final initialized = await initialize();
        if (!initialized) {
          return 0;
        }
      }

      // Get current step count from the stream
      // Note: Pedometer provides cumulative steps since device reboot
      // For daily steps, you would need to track the baseline at midnight
      // This is a simplified implementation
      if (_stepCountStream != null) {
        try {
          final stepCount = await _stepCountStream!.first.timeout(
            const Duration(seconds: 5),
          );
          _currentStepCount = stepCount.steps;
          _lastStepCountUpdate = DateTime.now();

          // Start listening for updates
          if (!_isListening) {
            startListening();
          }

          return _currentStepCount;
        } catch (e) {
          debugPrint('Error getting step count: $e');
          // Return cached value if available
          return _currentStepCount;
        }
      }

      return 0;
    } catch (e) {
      debugPrint('Error getting today steps: $e');
      return 0;
    }
  }

  // Start listening to step count updates
  void startListening() {
    if (_isListening || _stepCountStream == null) {
      return;
    }

    try {
      _stepCountStream!.listen(
        (StepCount event) {
          _currentStepCount = event.steps;
          _lastStepCountUpdate = DateTime.now();
        },
        onError: (error) {
          debugPrint('Error in step count stream: $error');
        },
        cancelOnError: false,
      );

      _isListening = true;
    } catch (e) {
      debugPrint('Error starting step count listener: $e');
    }
  }

  // Stop listening to step count updates
  void stopListening() {
    _isListening = false;
  }

  // Get steps for a specific date range
  // Note: This is a simplified implementation.
  // For more accurate results, you might want to use health packages
  Future<int> getStepsForDate(DateTime date) async {
    try {
      // The pedometer package provides current step count since last device reboot
      // For historical data, you would need to use health packages like 'health'
      // This implementation returns current steps if the date is today
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return await getTodaySteps();
      }

      // For past dates, return 0 (would need health package for historical data)
      return 0;
    } catch (e) {
      debugPrint('Error getting steps for date: $e');
      return 0;
    }
  }

  // Dispose resources
  void dispose() {
    stopListening();
    _stepCountStream = null;
  }
}
