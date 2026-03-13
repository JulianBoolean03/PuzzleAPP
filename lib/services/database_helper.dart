import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/mission.dart';
import '../models/puzzle.dart';
import '../models/clue.dart';
import '../models/game_session.dart';
import '../models/hint_record.dart';
import '../models/achievement.dart';

/// Singleton helper that manages the SQLite database lifecycle.
///
/// Provides typed CRUD methods for every model in the application.
/// The database is lazily initialized on first access.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'storypath.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Creates all tables on first database open.
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE missions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        story_intro TEXT NOT NULL DEFAULT '',
        story_conclusion TEXT NOT NULL DEFAULT '',
        is_unlocked INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE puzzles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mission_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        content TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        hint TEXT NOT NULL DEFAULT '',
        puzzle_type TEXT NOT NULL DEFAULT 'riddle',
        FOREIGN KEY (mission_id) REFERENCES missions (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE clues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mission_id INTEGER NOT NULL,
        clue_text TEXT NOT NULL,
        found_at TEXT NOT NULL,
        FOREIGN KEY (mission_id) REFERENCES missions (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mission_id INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        completion_time TEXT,
        score INTEGER NOT NULL DEFAULT 0,
        hints_used INTEGER NOT NULL DEFAULT 0,
        puzzles_solved INTEGER NOT NULL DEFAULT 0,
        total_puzzles INTEGER NOT NULL DEFAULT 0,
        is_complete INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (mission_id) REFERENCES missions (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE hint_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        puzzle_id INTEGER NOT NULL,
        hint_text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id)
          ON DELETE CASCADE,
        FOREIGN KEY (puzzle_id) REFERENCES puzzles (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL DEFAULT 'star',
        unlocked_at TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // Missions
  // ---------------------------------------------------------------------------

  Future<int> insertMission(Mission mission) async {
    final db = await database;
    return await db.insert('missions', mission.toMap());
  }

  Future<List<Mission>> getMissions() async {
    final db = await database;
    final rows = await db.query('missions', orderBy: 'id ASC');
    return rows.map((row) => Mission.fromMap(row)).toList();
  }

  Future<Mission?> getMission(int id) async {
    final db = await database;
    final rows = await db.query('missions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Mission.fromMap(rows.first);
  }

  Future<int> updateMission(Mission mission) async {
    final db = await database;
    return await db.update(
      'missions',
      mission.toMap(),
      where: 'id = ?',
      whereArgs: [mission.id],
    );
  }

  Future<int> deleteMission(int id) async {
    final db = await database;
    return await db.delete('missions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // Puzzles
  // ---------------------------------------------------------------------------

  Future<int> insertPuzzle(Puzzle puzzle) async {
    final db = await database;
    return await db.insert('puzzles', puzzle.toMap());
  }

  Future<List<Puzzle>> getPuzzlesForMission(int missionId) async {
    final db = await database;
    final rows = await db.query(
      'puzzles',
      where: 'mission_id = ?',
      whereArgs: [missionId],
      orderBy: 'order_index ASC',
    );
    return rows.map((row) => Puzzle.fromMap(row)).toList();
  }

  Future<Puzzle?> getPuzzle(int id) async {
    final db = await database;
    final rows = await db.query('puzzles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Puzzle.fromMap(rows.first);
  }

  Future<int> updatePuzzle(Puzzle puzzle) async {
    final db = await database;
    return await db.update(
      'puzzles',
      puzzle.toMap(),
      where: 'id = ?',
      whereArgs: [puzzle.id],
    );
  }

  Future<int> deletePuzzle(int id) async {
    final db = await database;
    return await db.delete('puzzles', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // Clues
  // ---------------------------------------------------------------------------

  Future<int> insertClue(Clue clue) async {
    final db = await database;
    return await db.insert('clues', clue.toMap());
  }

  Future<List<Clue>> getCluesForMission(int missionId) async {
    final db = await database;
    final rows = await db.query(
      'clues',
      where: 'mission_id = ?',
      whereArgs: [missionId],
      orderBy: 'found_at DESC',
    );
    return rows.map((row) => Clue.fromMap(row)).toList();
  }

  Future<int> deleteClue(int id) async {
    final db = await database;
    return await db.delete('clues', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // Game Sessions
  // ---------------------------------------------------------------------------

  Future<int> insertSession(GameSession session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<GameSession>> getSessionsForMission(int missionId) async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'mission_id = ?',
      whereArgs: [missionId],
      orderBy: 'start_time DESC',
    );
    return rows.map((row) => GameSession.fromMap(row)).toList();
  }

  Future<List<GameSession>> getAllCompletedSessions() async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'is_complete = 1',
      orderBy: 'score DESC',
    );
    return rows.map((row) => GameSession.fromMap(row)).toList();
  }

  Future<GameSession?> getSession(int id) async {
    final db = await database;
    final rows = await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return GameSession.fromMap(rows.first);
  }

  Future<int> updateSession(GameSession session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // Hint Records
  // ---------------------------------------------------------------------------

  Future<int> insertHintRecord(HintRecord record) async {
    final db = await database;
    return await db.insert('hint_records', record.toMap());
  }

  Future<List<HintRecord>> getHintRecordsForSession(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'hint_records',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map((row) => HintRecord.fromMap(row)).toList();
  }

  /// Gets all hint records for sessions belonging to a specific mission.
  Future<List<HintRecord>> getHintRecordsForMission(int missionId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT h.* FROM hint_records h
      INNER JOIN sessions s ON h.session_id = s.id
      WHERE s.mission_id = ?
      ORDER BY h.timestamp DESC
    ''', [missionId]);
    return rows.map((row) => HintRecord.fromMap(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------------------

  Future<int> insertAchievement(Achievement achievement) async {
    final db = await database;
    return await db.insert('achievements', achievement.toMap());
  }

  Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final rows = await db.query('achievements', orderBy: 'id ASC');
    return rows.map((row) => Achievement.fromMap(row)).toList();
  }

  Future<int> updateAchievement(Achievement achievement) async {
    final db = await database;
    return await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<int> unlockAchievement(int id) async {
    final db = await database;
    return await db.update(
      'achievements',
      {'unlocked_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Statistics helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;

    final totalSessions = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sessions WHERE is_complete = 1'),
    ) ?? 0;

    final totalHints = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM hint_records'),
    ) ?? 0;

    final avgScore = (await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM sessions WHERE is_complete = 1',
    )).first['avg_score'];

    final bestScore = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT MAX(score) FROM sessions WHERE is_complete = 1',
      ),
    ) ?? 0;

    final totalPuzzlesSolved = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT SUM(puzzles_solved) FROM sessions WHERE is_complete = 1',
      ),
    ) ?? 0;

    return {
      'total_sessions': totalSessions,
      'total_hints': totalHints,
      'avg_score': avgScore ?? 0.0,
      'best_score': bestScore,
      'total_puzzles_solved': totalPuzzlesSolved,
    };
  }

  /// Closes the database connection. Used primarily for testing.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
