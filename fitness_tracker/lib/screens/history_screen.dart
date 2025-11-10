import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/fitness_activity.dart';
import '../providers/fitness_provider.dart';
import 'add_activity_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  String? _selectedExerciseType;
  DateTime? _selectedDate;

  final List<String> _exerciseTypes = [
    'All Types',
    'Running',
    'Cycling',
    'Yoga',
    'Walking',
    'Swimming',
    'Weight Training',
    'HIIT',
    'Pilates',
    'Dancing',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity History',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              color: Colors.white,
            ),
          ),
        ],
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
        child: Column(
          children: [
            // Filter Chips
            if (_selectedFilter != 'All' || _selectedExerciseType != null || _selectedDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedFilter != 'All')
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Chip(
                          label: Text(
                            'Period: $_selectedFilter',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          },
                          deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    if (_selectedExerciseType != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Chip(
                          label: Text(
                            'Type: $_selectedExerciseType',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedExerciseType = null;
                            });
                          },
                          deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    if (_selectedDate != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Chip(
                          label: Text(
                            'Date: ${DateFormat('MM/dd/yyyy').format(_selectedDate!)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedDate = null;
                            });
                          },
                          deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                  ],
                ),
              ),

            // Activities List
            Expanded(
              child: fitnessProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildActivitiesList(context, fitnessProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, FitnessProvider fitnessProvider) {
    List<FitnessActivity> activities = _getFilteredActivities(fitnessProvider.activities);

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityCard(context, activity, fitnessProvider);
      },
    );
  }

  List<FitnessActivity> _getFilteredActivities(List<FitnessActivity> activities) {
    var filtered = activities;

    // Filter by period
    if (_selectedFilter != 'All') {
      final now = DateTime.now();
      switch (_selectedFilter) {
        case 'Today':
          filtered = filtered.where((a) {
            return a.date.year == now.year &&
                a.date.month == now.month &&
                a.date.day == now.day;
          }).toList();
          break;
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          filtered = filtered.where((a) => a.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))).toList();
          break;
        case 'This Month':
          filtered = filtered.where((a) {
            return a.date.year == now.year && a.date.month == now.month;
          }).toList();
          break;
      }
    }

    // Filter by exercise type
    if (_selectedExerciseType != null && _selectedExerciseType != 'All Types') {
      filtered = filtered.where((a) => a.exerciseType == _selectedExerciseType).toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      filtered = filtered.where((a) {
        return a.date.year == _selectedDate!.year &&
            a.date.month == _selectedDate!.month &&
            a.date.day == _selectedDate!.day;
      }).toList();
    }

    return filtered;
  }

  Widget _buildActivityCard(
    BuildContext context,
    FitnessActivity activity,
    FitnessProvider fitnessProvider,
  ) {
    final exerciseColor = _getExerciseColor(activity.exerciseType);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddActivityScreen(activity: activity),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        exerciseColor,
                        exerciseColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _getExerciseIcon(activity.exerciseType),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.exerciseType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.duration} min',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.calories.toStringAsFixed(0)} cal',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_walk, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.steps} steps',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MM/dd HH:mm').format(activity.date),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddActivityScreen(activity: activity),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, activity, fitnessProvider);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FitnessActivity activity,
    FitnessProvider fitnessProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete this ${activity.exerciseType} activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await fitnessProvider.deleteActivity(activity.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Period Filter
              const Text('Period:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: ['All', 'Today', 'This Week', 'This Month']
                    .map((filter) => FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            Navigator.pop(context);
                            _showFilterDialog();
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Exercise Type Filter
              const Text('Exercise Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _exerciseTypes.map((type) {
                  final isSelected = _selectedExerciseType == type ||
                      (_selectedExerciseType == null && type == 'All Types');
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExerciseType = selected && type != 'All Types' ? type : null;
                      });
                      Navigator.pop(context);
                      _showFilterDialog();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date Filter
              const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (!mounted) return;
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    Navigator.pop(context);
                    _showFilterDialog();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate != null
                    ? DateFormat('MM/dd/yyyy').format(_selectedDate!)
                    : 'Select Date'),
              ),
              if (_selectedDate != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    Navigator.pop(context);
                    _showFilterDialog();
                  },
                  child: const Text('Clear Date'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _selectedExerciseType = null;
                _selectedDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'running':
        return Colors.red;
      case 'cycling':
        return Colors.blue;
      case 'yoga':
        return Colors.purple;
      case 'walking':
        return Colors.green;
      case 'swimming':
        return Colors.cyan;
      case 'weight training':
        return Colors.orange;
      case 'hiit':
        return Colors.deepOrange;
      case 'pilates':
        return Colors.pink;
      case 'dancing':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseIcon(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'yoga':
        return Icons.self_improvement;
      case 'walking':
        return Icons.directions_walk;
      case 'swimming':
        return Icons.pool;
      case 'weight training':
        return Icons.fitness_center;
      case 'hiit':
        return Icons.speed;
      case 'pilates':
        return Icons.accessibility_new;
      case 'dancing':
        return Icons.music_note;
      default:
        return Icons.fitness_center;
    }
  }
}
