import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../models/fitness_activity.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _dailyStepGoalController = TextEditingController();
  final _dailyCalorieGoalController = TextEditingController();
  final _dailyWorkoutGoalController = TextEditingController();
  final _weeklyStepGoalController = TextEditingController();
  final _weeklyCalorieGoalController = TextEditingController();
  final _weeklyWorkoutGoalController = TextEditingController();
  final _monthlyStepGoalController = TextEditingController();
  final _monthlyCalorieGoalController = TextEditingController();
  final _monthlyWorkoutGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    _dailyStepGoalController.text = goalsProvider.goals.dailyStepGoal
        .toString();
    _dailyCalorieGoalController.text = goalsProvider.goals.dailyCalorieGoal
        .toStringAsFixed(0);
    _dailyWorkoutGoalController.text = goalsProvider.goals.dailyWorkoutGoal
        .toString();
    _weeklyStepGoalController.text = goalsProvider.goals.weeklyStepGoal
        .toString();
    _weeklyCalorieGoalController.text = goalsProvider.goals.weeklyCalorieGoal
        .toStringAsFixed(0);
    _weeklyWorkoutGoalController.text = goalsProvider.goals.weeklyWorkoutGoal
        .toString();
    _monthlyStepGoalController.text = goalsProvider.goals.monthlyStepGoal
        .toString();
    _monthlyCalorieGoalController.text = goalsProvider.goals.monthlyCalorieGoal
        .toStringAsFixed(0);
    _monthlyWorkoutGoalController.text = goalsProvider.goals.monthlyWorkoutGoal
        .toString();
  }

  @override
  void dispose() {
    _dailyStepGoalController.dispose();
    _dailyCalorieGoalController.dispose();
    _dailyWorkoutGoalController.dispose();
    _weeklyStepGoalController.dispose();
    _weeklyCalorieGoalController.dispose();
    _weeklyWorkoutGoalController.dispose();
    _monthlyStepGoalController.dispose();
    _monthlyCalorieGoalController.dispose();
    _monthlyWorkoutGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Goals Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitness Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set your fitness targets',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Daily Goals Section
                  Text(
                    'Daily Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daily Step Goal
                  TextField(
                    controller: _dailyStepGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Step Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_walk),
                      suffixText: 'steps',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Daily Calorie Goal
                  TextField(
                    controller: _dailyCalorieGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Calorie Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'calories',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Daily Workout Goal
                  TextField(
                    controller: _dailyWorkoutGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Workout Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      suffixText: 'minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Weekly Goals Section
                  Text(
                    'Weekly Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weekly Step Goal
                  TextField(
                    controller: _weeklyStepGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Step Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_walk),
                      suffixText: 'steps',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Weekly Calorie Goal
                  TextField(
                    controller: _weeklyCalorieGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Calorie Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'calories',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Weekly Workout Goal
                  TextField(
                    controller: _weeklyWorkoutGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Workout Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      suffixText: 'minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Monthly Goals Section
                  Text(
                    'Monthly Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Monthly Step Goal
                  TextField(
                    controller: _monthlyStepGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Step Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_walk),
                      suffixText: 'steps',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Monthly Calorie Goal
                  TextField(
                    controller: _monthlyCalorieGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Calorie Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'calories',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Monthly Workout Goal
                  TextField(
                    controller: _monthlyWorkoutGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Workout Goal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      suffixText: 'minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Save Goals Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveGoals(goalsProvider),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Goals'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Info Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('About'),
                    subtitle: const Text('Fitness Tracker App'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveGoals(GoalsProvider goalsProvider) {
    final dailyStepGoal = int.tryParse(_dailyStepGoalController.text);
    final dailyCalorieGoal = double.tryParse(_dailyCalorieGoalController.text);
    final dailyWorkoutGoal = int.tryParse(_dailyWorkoutGoalController.text);
    final weeklyStepGoal = int.tryParse(_weeklyStepGoalController.text);
    final weeklyCalorieGoal = double.tryParse(
      _weeklyCalorieGoalController.text,
    );
    final weeklyWorkoutGoal = int.tryParse(_weeklyWorkoutGoalController.text);
    final monthlyStepGoal = int.tryParse(_monthlyStepGoalController.text);
    final monthlyCalorieGoal = double.tryParse(
      _monthlyCalorieGoalController.text,
    );
    final monthlyWorkoutGoal = int.tryParse(_monthlyWorkoutGoalController.text);

    if (dailyStepGoal == null || dailyStepGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid daily step goal')),
      );
      return;
    }

    if (dailyCalorieGoal == null || dailyCalorieGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid daily calorie goal'),
        ),
      );
      return;
    }

    if (dailyWorkoutGoal == null || dailyWorkoutGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid daily workout goal'),
        ),
      );
      return;
    }

    if (weeklyStepGoal == null || weeklyStepGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weekly step goal')),
      );
      return;
    }

    if (weeklyCalorieGoal == null || weeklyCalorieGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weekly calorie goal'),
        ),
      );
      return;
    }

    if (weeklyWorkoutGoal == null || weeklyWorkoutGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weekly workout goal'),
        ),
      );
      return;
    }

    if (monthlyStepGoal == null || monthlyStepGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid monthly step goal')),
      );
      return;
    }

    if (monthlyCalorieGoal == null || monthlyCalorieGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly calorie goal'),
        ),
      );
      return;
    }

    if (monthlyWorkoutGoal == null || monthlyWorkoutGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly workout goal'),
        ),
      );
      return;
    }

    final newGoals = FitnessGoals(
      dailyStepGoal: dailyStepGoal,
      dailyCalorieGoal: dailyCalorieGoal,
      dailyWorkoutGoal: dailyWorkoutGoal,
      weeklyStepGoal: weeklyStepGoal,
      weeklyCalorieGoal: weeklyCalorieGoal,
      weeklyWorkoutGoal: weeklyWorkoutGoal,
      monthlyStepGoal: monthlyStepGoal,
      monthlyCalorieGoal: monthlyCalorieGoal,
      monthlyWorkoutGoal: monthlyWorkoutGoal,
    );

    goalsProvider
        .updateGoals(newGoals)
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Goals saved successfully')),
            );
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving goals: $error')),
            );
          }
        });
  }
}
