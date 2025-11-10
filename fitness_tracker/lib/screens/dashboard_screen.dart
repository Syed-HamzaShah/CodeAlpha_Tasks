import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/fitness_provider.dart';
import '../providers/goals_provider.dart';
import '../models/fitness_activity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Daily'; // Daily, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    final goalsProvider = Provider.of<GoalsProvider>(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade600,
                Colors.purple.shade600,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => fitnessProvider.loadActivities(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Daily', 'Weekly', 'Monthly']
                        .map((period) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FilterChip(
                                  label: Text(period),
                                  selected: _selectedPeriod == period,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedPeriod = period;
                                    });
                                  },
                                  selectedColor: Colors.blue.shade100,
                                  checkmarkColor: Colors.blue.shade700,
                                  labelStyle: TextStyle(
                                    color: _selectedPeriod == period
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade700,
                                    fontWeight: _selectedPeriod == period
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Cards
                _buildProgressCards(context, fitnessProvider, goalsProvider, now),
                const SizedBox(height: 24),

                // Charts
                _buildCharts(context, fitnessProvider, now),
                const SizedBox(height: 24),

                // Recent Activities
                _buildRecentActivities(context, fitnessProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCards(
    BuildContext context,
    FitnessProvider fitnessProvider,
    GoalsProvider goalsProvider,
    DateTime date,
  ) {
    Future<List<FitnessActivity>> activities;
    switch (_selectedPeriod) {
      case 'Weekly':
        activities = fitnessProvider.getActivitiesForWeek(date);
        break;
      case 'Monthly':
        activities = fitnessProvider.getActivitiesForMonth(date);
        break;
      default:
        activities = fitnessProvider.getActivitiesForDate(date);
    }

    return FutureBuilder<List<FitnessActivity>>(
      future: activities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = snapshot.data ?? [];
        final totalCalories = fitnessProvider.getTotalCalories(activities);
        final totalSteps = fitnessProvider.getTotalSteps(activities);
        final totalDuration = fitnessProvider.getTotalDuration(activities);
        final totalWorkouts = fitnessProvider.getTotalWorkouts(activities);

        final goals = goalsProvider.goals;
        final calorieProgress = (totalCalories / goals.dailyCalorieGoal).clamp(0.0, 1.0);
        final stepProgress = (totalSteps / goals.dailyStepGoal).clamp(0.0, 1.0);
        final workoutProgress = totalWorkouts > 0
            ? (totalDuration / (goals.dailyWorkoutGoal * totalWorkouts)).clamp(0.0, 1.0)
            : 0.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Calories',
                    '${totalCalories.toStringAsFixed(0)} / ${goals.dailyCalorieGoal.toStringAsFixed(0)}',
                    Icons.local_fire_department,
                    Colors.orange,
                    calorieProgress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Steps',
                    '$totalSteps / ${goals.dailyStepGoal}',
                    Icons.directions_walk,
                    Colors.blue,
                    stepProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Duration',
                    '$totalDuration min',
                    Icons.timer,
                    Colors.green,
                    workoutProgress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Workouts',
                    '$totalWorkouts',
                    Icons.fitness_center,
                    Colors.purple,
                    totalWorkouts > 0 ? 1.0 : 0.0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(
    BuildContext context,
    FitnessProvider fitnessProvider,
    DateTime date,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.purple.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_selectedPeriod Progress',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<FitnessActivity>>(
                future: _getActivitiesForPeriod(fitnessProvider, date),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activities = snapshot.data ?? [];
                  return _buildCaloriesChart(activities);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<FitnessActivity>> _getActivitiesForPeriod(
    FitnessProvider provider,
    DateTime date,
  ) {
    switch (_selectedPeriod) {
      case 'Weekly':
        return provider.getActivitiesForWeek(date);
      case 'Monthly':
        return provider.getActivitiesForMonth(date);
      default:
        return provider.getActivitiesForDate(date);
    }
  }

  Widget _buildCaloriesChart(List<FitnessActivity> activities) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    // Group activities by date
    final Map<String, double> dailyCalories = {};
    for (var activity in activities) {
      final dateKey = DateFormat('MM/dd').format(activity.date);
      dailyCalories[dateKey] = (dailyCalories[dateKey] ?? 0) + activity.calories;
    }

    final sortedDates = dailyCalories.keys.toList()..sort();
    final maxCalories = dailyCalories.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCalories * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBgColor: Colors.blue.shade700,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedDates[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCalories * 1.2 / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        barGroups: sortedDates.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;
          final calories = dailyCalories[date]!;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: calories,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade400,
                  ],
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivities(
    BuildContext context,
    FitnessProvider fitnessProvider,
  ) {
    final activities = fitnessProvider.activities.take(5).toList();

    if (activities.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first activity to get started!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.purple.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity.exerciseType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${activity.duration} min • ${activity.calories.toStringAsFixed(0)} cal',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Text(
                    DateFormat('MM/dd HH:mm').format(activity.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
