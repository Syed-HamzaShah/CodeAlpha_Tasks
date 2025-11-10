import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_activity.dart';

class GoalsProvider with ChangeNotifier {
  FitnessGoals _goals = FitnessGoals();
  FitnessGoals get goals => _goals;

  GoalsProvider() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stepGoal = prefs.getInt('dailyStepGoal') ?? 10000;
      final calorieGoal = prefs.getDouble('dailyCalorieGoal') ?? 500.0;
      final workoutGoal = prefs.getInt('dailyWorkoutGoal') ?? 30;
      final weeklyStepGoal = prefs.getInt('weeklyStepGoal') ?? 70000;
      final weeklyCalorieGoal = prefs.getDouble('weeklyCalorieGoal') ?? 3500.0;
      final weeklyWorkoutGoal = prefs.getInt('weeklyWorkoutGoal') ?? 210;
      final monthlyStepGoal = prefs.getInt('monthlyStepGoal') ?? 300000;
      final monthlyCalorieGoal = prefs.getDouble('monthlyCalorieGoal') ?? 15000.0;
      final monthlyWorkoutGoal = prefs.getInt('monthlyWorkoutGoal') ?? 900;

      _goals = FitnessGoals(
        dailyStepGoal: stepGoal,
        dailyCalorieGoal: calorieGoal,
        dailyWorkoutGoal: workoutGoal,
        weeklyStepGoal: weeklyStepGoal,
        weeklyCalorieGoal: weeklyCalorieGoal,
        weeklyWorkoutGoal: weeklyWorkoutGoal,
        monthlyStepGoal: monthlyStepGoal,
        monthlyCalorieGoal: monthlyCalorieGoal,
        monthlyWorkoutGoal: monthlyWorkoutGoal,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  Future<void> updateGoals(FitnessGoals newGoals) async {
    try {
      _goals = newGoals;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dailyStepGoal', newGoals.dailyStepGoal);
      await prefs.setDouble('dailyCalorieGoal', newGoals.dailyCalorieGoal);
      await prefs.setInt('dailyWorkoutGoal', newGoals.dailyWorkoutGoal);
      await prefs.setInt('weeklyStepGoal', newGoals.weeklyStepGoal);
      await prefs.setDouble('weeklyCalorieGoal', newGoals.weeklyCalorieGoal);
      await prefs.setInt('weeklyWorkoutGoal', newGoals.weeklyWorkoutGoal);
      await prefs.setInt('monthlyStepGoal', newGoals.monthlyStepGoal);
      await prefs.setDouble('monthlyCalorieGoal', newGoals.monthlyCalorieGoal);
      await prefs.setInt('monthlyWorkoutGoal', newGoals.monthlyWorkoutGoal);
    } catch (e) {
      debugPrint('Error updating goals: $e');
      rethrow;
    }
  }
}
