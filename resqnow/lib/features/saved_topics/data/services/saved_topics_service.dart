import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/saved_condition_model.dart';

class SavedTopicsService {
  static final SavedTopicsService _instance = SavedTopicsService._internal();
  static Database? _database;
  static bool _initializing = false;

  factory SavedTopicsService() {
    return _instance;
  }

  SavedTopicsService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Prevent multiple simultaneous initialization attempts
    while (_initializing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_database != null) return _database!;

    _initializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _initializing = false;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'saved_topics.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_conditions(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrls TEXT NOT NULL,
        severity TEXT NOT NULL,
        firstAidDescription TEXT NOT NULL,
        doNotDo TEXT NOT NULL,
        videoUrl TEXT NOT NULL,
        requiredKits TEXT NOT NULL,
        faqs TEXT NOT NULL,
        doctorType TEXT NOT NULL,
        hospitalLocatorLink TEXT NOT NULL,
        savedAt INTEGER NOT NULL
      )
    ''');
  }

  /// Save a condition to the database
  Future<int> saveCondition(SavedConditionModel condition) async {
    final db = await database;
    try {
      // Check if condition already exists
      final existing = await db.query(
        'saved_conditions',
        where: 'id = ?',
        whereArgs: [condition.id],
      );

      if (existing.isNotEmpty) {
        // Update if exists
        return await db.update(
          'saved_conditions',
          condition.toMap(),
          where: 'id = ?',
          whereArgs: [condition.id],
        );
      } else {
        // Insert new
        return await db.insert('saved_conditions', condition.toMap());
      }
    } catch (e) {
      throw Exception('Failed to save condition: $e');
    }
  }

  /// Get all saved conditions
  Future<List<SavedConditionModel>> getSavedConditions() async {
    final db = await database;
    try {
      final maps = await db.query('saved_conditions', orderBy: 'savedAt DESC');

      return List.generate(maps.length, (i) {
        return SavedConditionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to fetch saved conditions: $e');
    }
  }

  /// Delete a saved condition
  Future<int> deleteCondition(String conditionId) async {
    final db = await database;
    try {
      return await db.delete(
        'saved_conditions',
        where: 'id = ?',
        whereArgs: [conditionId],
      );
    } catch (e) {
      throw Exception('Failed to delete condition: $e');
    }
  }

  /// Check if a condition is saved
  Future<bool> isConditionSaved(String conditionId) async {
    final db = await database;
    try {
      final result = await db.query(
        'saved_conditions',
        where: 'id = ?',
        whereArgs: [conditionId],
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check condition: $e');
    }
  }

  /// Clear all saved conditions
  Future<int> clearAllConditions() async {
    final db = await database;
    try {
      return await db.delete('saved_conditions');
    } catch (e) {
      throw Exception('Failed to clear conditions: $e');
    }
  }
}
