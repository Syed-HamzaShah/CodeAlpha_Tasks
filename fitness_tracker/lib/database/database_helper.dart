import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fitness_activity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseType TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories REAL NOT NULL,
        steps INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> createActivity(FitnessActivity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<FitnessActivity>> getAllActivities() async {
    final db = await database;
    final result = await db.query(
      'activities',
      orderBy: 'date DESC',
    );
    return result.map((map) => FitnessActivity.fromMap(map)).toList();
  }

  Future<List<FitnessActivity>> getActivitiesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'activities',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return result.map((map) => FitnessActivity.fromMap(map)).toList();
  }

  Future<List<FitnessActivity>> getActivitiesByType(String exerciseType) async {
    final db = await database;
    final result = await db.query(
      'activities',
      where: 'exerciseType = ?',
      whereArgs: [exerciseType],
      orderBy: 'date DESC',
    );
    return result.map((map) => FitnessActivity.fromMap(map)).toList();
  }

  Future<FitnessActivity?> getActivityById(int id) async {
    final db = await database;
    final result = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return FitnessActivity.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateActivity(FitnessActivity activity) async {
    final db = await database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FitnessActivity>> getActivitiesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await getActivitiesByDateRange(startOfDay, endOfDay);
  }

  Future<List<FitnessActivity>> getActivitiesForWeek(DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfDay = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    return await getActivitiesByDateRange(startOfDay, endOfDay);
  }

  Future<List<FitnessActivity>> getActivitiesForMonth(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return await getActivitiesByDateRange(startOfMonth, endOfMonth);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
