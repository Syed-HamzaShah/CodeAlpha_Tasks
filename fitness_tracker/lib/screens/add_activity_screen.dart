import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fitness_activity.dart';
import '../providers/fitness_provider.dart';
import '../services/step_counter_service.dart';

class AddActivityScreen extends StatefulWidget {
  final FitnessActivity? activity;

  const AddActivityScreen({super.key, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedExerciseType;

  final StepCounterService _stepCounterService = StepCounterService();
  bool _isLoadingSteps = false;

  final List<String> _exerciseTypes = [
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

  // Activities that involve steps (require step count)
  final List<String> _stepBasedActivities = [
    'Running',
    'Walking',
  ];

  bool get _requiresSteps {
    return _selectedExerciseType != null &&
        _stepBasedActivities.contains(_selectedExerciseType);
  }

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _selectedExerciseType = widget.activity!.exerciseType;
      _exerciseTypeController.text = widget.activity!.exerciseType;
      _durationController.text = widget.activity!.duration.toString();
      _caloriesController.text = widget.activity!.calories.toString();
      _stepsController.text = widget.activity!.steps.toString();
      _selectedDate = widget.activity!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.activity!.date);
    } else {
      // Initialize steps to 0 for new activities
      _stepsController.text = '0';
    }
    // Initialize step counter service
    _stepCounterService.initialize();
  }

  @override
  void dispose() {
    _exerciseTypeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    _stepCounterService.dispose();
    super.dispose();
  }

  Future<void> _fetchStepsFromDevice() async {
    setState(() {
      _isLoadingSteps = true;
    });

    try {
      // Check if permission is granted
      final hasPermission = await _stepCounterService.isPermissionGranted();

      if (!hasPermission) {
        // Request permission
        final granted = await _stepCounterService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Permission denied. Please grant activity recognition permission to track steps.',
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }
          setState(() {
            _isLoadingSteps = false;
          });
          return;
        }
      }

      // Initialize if not already initialized
      final initialized = await _stepCounterService.initialize();
      if (!initialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to initialize step counter. Please check if your device supports step counting.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _isLoadingSteps = false;
        });
        return;
      }

      // Get today's steps
      final steps = await _stepCounterService.getTodaySteps();

      if (mounted) {
        setState(() {
          _stepsController.text = steps.toString();
          _isLoadingSteps = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fetched $steps steps from device'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSteps = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching steps: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Parse steps: for step-based activities, use value from controller
        // For non-step activities: always use 0 (steps not relevant for these activities)
        final steps = _requiresSteps
            ? int.parse(_stepsController.text.trim().isNotEmpty
                ? _stepsController.text.trim()
                : '0')
            : 0; // Non-step activities always use 0 for steps

        final activity = FitnessActivity(
          id: widget.activity?.id,
          exerciseType:
              _selectedExerciseType ?? _exerciseTypeController.text.trim(),
          duration: int.parse(_durationController.text),
          calories: double.parse(_caloriesController.text),
          steps: steps,
          date: dateTime,
        );

        final fitnessProvider = Provider.of<FitnessProvider>(
          context,
          listen: false,
        );

        if (widget.activity != null) {
          await fitnessProvider.updateActivity(activity);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity updated successfully')),
            );
            Navigator.of(context).pop();
          }
        } else {
          await fitnessProvider.addActivity(activity);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity added successfully')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activity != null ? 'Edit Activity' : 'Add Activity',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.fitness_center, size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        widget.activity != null
                            ? 'Edit Your Activity'
                            : 'Track Your Progress',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Exercise Type Dropdown
                Container(
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
                  child: DropdownButtonFormField<String>(
                    value: _selectedExerciseType,
                    decoration: InputDecoration(
                      labelText: 'Exercise Type',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    items: _exerciseTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedExerciseType = value;
                        _exerciseTypeController.text = value ?? '';
                        // Reset steps to 0 when switching to non-step activity
                        if (value != null && !_stepBasedActivities.contains(value)) {
                          _stepsController.text = '0';
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an exercise type';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Duration Input
                _buildStyledTextField(
                  controller: _durationController,
                  label: 'Duration (minutes)',
                  icon: Icons.timer,
                  iconColor: Colors.green,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Calories Input
                _buildStyledTextField(
                  controller: _caloriesController,
                  label: 'Calories Burned',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) < 0) {
                      return 'Please enter a valid calorie count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Steps Input with Device Fetch Button (only for step-based activities)
                if (_requiresSteps) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStyledTextField(
                        controller: _stepsController,
                        label: 'Steps Taken',
                        icon: Icons.directions_walk,
                        iconColor: Colors.blue,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter steps';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Please enter a valid step count';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _isLoadingSteps
                              ? null
                              : _fetchStepsFromDevice,
                          icon: _isLoadingSteps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sensors),
                          label: Text(
                            _isLoadingSteps
                                ? 'Fetching steps...'
                                : 'Get Steps from Device',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: BorderSide(
                              color: Colors.blue.shade400,
                              width: 2,
                            ),
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Date Picker
                _buildPickerCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.purple,
                  title: 'Date',
                  subtitle:
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                // Time Picker
                _buildPickerCard(
                  icon: Icons.access_time,
                  iconColor: Colors.teal,
                  title: 'Time',
                  subtitle: _selectedTime.format(context),
                  onTap: _selectTime,
                ),
                const SizedBox(height: 32),

                // Submit Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.activity != null
                          ? 'Update Activity'
                          : 'Add Activity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
