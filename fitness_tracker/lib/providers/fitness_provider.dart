import 'package:flutter/foundation.dart';
import '../models/fitness_activity.dart';
import '../database/database_helper.dart';

class FitnessProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<FitnessActivity> _activities = [];
  bool _isLoading = false;

  List<FitnessActivity> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activities = await _dbHelper.getAllActivities();
    } catch (e) {
      debugPrint('Error loading activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(FitnessActivity activity) async {
    try {
      await _dbHelper.createActivity(activity);
      await loadActivities();
    } catch (e) {
      debugPrint('Error adding activity: $e');
      rethrow;
    }
  }

  Future<void> updateActivity(FitnessActivity activity) async {
    try {
      await _dbHelper.updateActivity(activity);
      await loadActivities();
    } catch (e) {
      debugPrint('Error updating activity: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _dbHelper.deleteActivity(id);
      await loadActivities();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      rethrow;
    }
  }

  Future<List<FitnessActivity>> getActivitiesForDate(DateTime date) async {
    try {
      return await _dbHelper.getActivitiesForDate(date);
    } catch (e) {
      debugPrint('Error getting activities for date: $e');
      return [];
    }
  }

  Future<List<FitnessActivity>> getActivitiesForWeek(DateTime date) async {
    try {
      return await _dbHelper.getActivitiesForWeek(date);
    } catch (e) {
      debugPrint('Error getting activities for week: $e');
      return [];
    }
  }

  Future<List<FitnessActivity>> getActivitiesForMonth(DateTime date) async {
    try {
      return await _dbHelper.getActivitiesForMonth(date);
    } catch (e) {
      debugPrint('Error getting activities for month: $e');
      return [];
    }
  }

  List<FitnessActivity> getActivitiesByType(String exerciseType) {
    return _activities.where((a) => a.exerciseType == exerciseType).toList();
  }

  double getTotalCalories(List<FitnessActivity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.calories);
  }

  int getTotalSteps(List<FitnessActivity> activities) {
    return activities.fold(0, (sum, activity) => sum + activity.steps);
  }

  int getTotalDuration(List<FitnessActivity> activities) {
    return activities.fold(0, (sum, activity) => sum + activity.duration);
  }

  int getTotalWorkouts(List<FitnessActivity> activities) {
    return activities.length;
  }
}
