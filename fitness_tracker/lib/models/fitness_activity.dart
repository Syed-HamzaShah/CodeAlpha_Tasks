class FitnessActivity {
  final int? id;
  final String exerciseType;
  final int duration; // in minutes
  final double calories;
  final int steps;
  final DateTime date;

  FitnessActivity({
    this.id,
    required this.exerciseType,
    required this.duration,
    required this.calories,
    required this.steps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'duration': duration,
      'calories': calories,
      'steps': steps,
      'date': date.toIso8601String(),
    };
  }

  factory FitnessActivity.fromMap(Map<String, dynamic> map) {
    return FitnessActivity(
      id: map['id'] as int?,
      exerciseType: map['exerciseType'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as double,
      steps: map['steps'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }

  FitnessActivity copyWith({
    int? id,
    String? exerciseType,
    int? duration,
    double? calories,
    int? steps,
    DateTime? date,
  }) {
    return FitnessActivity(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      date: date ?? this.date,
    );
  }
}

class FitnessGoals {
  final int dailyStepGoal;
  final double dailyCalorieGoal;
  final int dailyWorkoutGoal;
  final int weeklyStepGoal;
  final double weeklyCalorieGoal;
  final int weeklyWorkoutGoal;
  final int monthlyStepGoal;
  final double monthlyCalorieGoal;
  final int monthlyWorkoutGoal;

  FitnessGoals({
    this.dailyStepGoal = 10000,
    this.dailyCalorieGoal = 500.0,
    this.dailyWorkoutGoal = 30, // minutes
    this.weeklyStepGoal = 70000, // 7 days * 10000
    this.weeklyCalorieGoal = 3500.0, // 7 days * 500
    this.weeklyWorkoutGoal = 210, // 7 days * 30 minutes
    this.monthlyStepGoal = 300000, // 30 days * 10000
    this.monthlyCalorieGoal = 15000.0, // 30 days * 500
    this.monthlyWorkoutGoal = 900, // 30 days * 30 minutes
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyStepGoal': dailyStepGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyWorkoutGoal': dailyWorkoutGoal,
      'weeklyStepGoal': weeklyStepGoal,
      'weeklyCalorieGoal': weeklyCalorieGoal,
      'weeklyWorkoutGoal': weeklyWorkoutGoal,
      'monthlyStepGoal': monthlyStepGoal,
      'monthlyCalorieGoal': monthlyCalorieGoal,
      'monthlyWorkoutGoal': monthlyWorkoutGoal,
    };
  }

  factory FitnessGoals.fromMap(Map<String, dynamic> map) {
    return FitnessGoals(
      dailyStepGoal: map['dailyStepGoal'] as int? ?? 10000,
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toDouble() ?? 500.0,
      dailyWorkoutGoal: map['dailyWorkoutGoal'] as int? ?? 30,
      weeklyStepGoal: map['weeklyStepGoal'] as int? ?? 70000,
      weeklyCalorieGoal: (map['weeklyCalorieGoal'] as num?)?.toDouble() ?? 3500.0,
      weeklyWorkoutGoal: map['weeklyWorkoutGoal'] as int? ?? 210,
      monthlyStepGoal: map['monthlyStepGoal'] as int? ?? 300000,
      monthlyCalorieGoal: (map['monthlyCalorieGoal'] as num?)?.toDouble() ?? 15000.0,
      monthlyWorkoutGoal: map['monthlyWorkoutGoal'] as int? ?? 900,
    );
  }

  FitnessGoals copyWith({
    int? dailyStepGoal,
    double? dailyCalorieGoal,
    int? dailyWorkoutGoal,
    int? weeklyStepGoal,
    double? weeklyCalorieGoal,
    int? weeklyWorkoutGoal,
    int? monthlyStepGoal,
    double? monthlyCalorieGoal,
    int? monthlyWorkoutGoal,
  }) {
    return FitnessGoals(
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWorkoutGoal: dailyWorkoutGoal ?? this.dailyWorkoutGoal,
      weeklyStepGoal: weeklyStepGoal ?? this.weeklyStepGoal,
      weeklyCalorieGoal: weeklyCalorieGoal ?? this.weeklyCalorieGoal,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      monthlyStepGoal: monthlyStepGoal ?? this.monthlyStepGoal,
      monthlyCalorieGoal: monthlyCalorieGoal ?? this.monthlyCalorieGoal,
      monthlyWorkoutGoal: monthlyWorkoutGoal ?? this.monthlyWorkoutGoal,
    );
  }
}
