import 'package:flutter/foundation.dart';

import '../models/mission.dart';
import '../models/puzzle.dart';
import '../models/clue.dart';
import '../models/game_session.dart';
import '../models/hint_record.dart';
import '../models/achievement.dart';
import '../services/database_helper.dart';
import '../services/seed_data.dart';

/// Central state manager for the entire game.
///
/// Exposes reactive lists for missions, sessions, achievements, etc.
/// All mutations go through [DatabaseHelper] and then refresh the
/// in-memory cache so that listeners rebuild automatically.
class GameProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  // ── Cached state ──
  List<Mission> _missions = [];
  List<Puzzle> _currentPuzzles = [];
  List<Clue> _currentClues = [];
  List<GameSession> _sessions = [];
  List<HintRecord> _currentHints = [];
  List<HintRecord> _missionHintHistory = [];
  List<Achievement> _achievements = [];
  Map<String, dynamic> _stats = {};

  bool _isLoading = true;
  Mission? _activeMission;
  GameSession? _activeSession;
  int _currentPuzzleIndex = 0;

  // ── Public getters ──
  List<Mission> get missions => _missions;
  List<Puzzle> get currentPuzzles => _currentPuzzles;
  List<Clue> get currentClues => _currentClues;
  List<GameSession> get sessions => _sessions;
  List<HintRecord> get currentHints => _currentHints;
  List<HintRecord> get missionHintHistory => _missionHintHistory;
  List<Achievement> get achievements => _achievements;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  Mission? get activeMission => _activeMission;
  GameSession? get activeSession => _activeSession;
  int get currentPuzzleIndex => _currentPuzzleIndex;

  Puzzle? get currentPuzzle {
    if (_currentPuzzles.isEmpty ||
        _currentPuzzleIndex >= _currentPuzzles.length) {
      return null;
    }
    return _currentPuzzles[_currentPuzzleIndex];
  }

  // ── Initialization ──

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await SeedData(_db).initialize();
    await refreshMissions();
    await refreshAchievements();
    await refreshStats();

    _isLoading = false;
    notifyListeners();
  }

  // ── Missions ──

  Future<void> refreshMissions() async {
    _missions = await _db.getMissions();
    notifyListeners();
  }

  Future<void> selectMission(Mission mission) async {
    _activeMission = mission;
    _currentPuzzleIndex = 0;
    _currentPuzzles = await _db.getPuzzlesForMission(mission.id!);
    _currentClues = await _db.getCluesForMission(mission.id!);
    _missionHintHistory = await _db.getHintRecordsForMission(mission.id!);
    _sessions = await _db.getSessionsForMission(mission.id!);
    notifyListeners();
  }

  /// Unlocks the next mission in sequence after completing the current one.
  Future<void> _unlockNextMission() async {
    if (_activeMission == null) return;
    final currentIndex =
        _missions.indexWhere((m) => m.id == _activeMission!.id);
    if (currentIndex < 0 || currentIndex >= _missions.length - 1) return;

    final next = _missions[currentIndex + 1];
    if (!next.isUnlocked) {
      final unlocked = next.copyWith(isUnlocked: true);
      await _db.updateMission(unlocked);
      await refreshMissions();
    }
  }

  // ── Game Sessions ──

  Future<void> startSession() async {
    if (_activeMission == null) return;

    final session = GameSession(
      missionId: _activeMission!.id!,
      startTime: DateTime.now().toIso8601String(),
      totalPuzzles: _currentPuzzles.length,
    );
    final id = await _db.insertSession(session);
    _activeSession = (await _db.getSession(id))!;
    _currentPuzzleIndex = 0;
    _currentHints = [];
    notifyListeners();
  }

  /// Validates the player's answer for the current puzzle.
  /// Returns `true` if correct, `false` otherwise.
  Future<bool> submitAnswer(String answer) async {
    final puzzle = currentPuzzle;
    if (puzzle == null || _activeSession == null) return false;

    final isCorrect =
        answer.trim().toUpperCase() == puzzle.answer.toUpperCase();

    if (isCorrect) {
      // Record a clue for solving this puzzle
      await _db.insertClue(Clue(
        missionId: _activeMission!.id!,
        clueText: 'Solved: ${puzzle.question}',
        foundAt: DateTime.now().toIso8601String(),
      ));

      final solved = _activeSession!.puzzlesSolved + 1;
      final basePoints = _difficultyMultiplier * 100;
      final hintPenalty = _currentHints.length * 25;
      final earned = (basePoints - hintPenalty).clamp(10, 500).toInt();

      _activeSession = _activeSession!.copyWith(
        puzzlesSolved: solved,
        score: _activeSession!.score + earned,
      );
      await _db.updateSession(_activeSession!);

      // Advance to next puzzle or complete the mission
      if (_currentPuzzleIndex < _currentPuzzles.length - 1) {
        _currentPuzzleIndex++;
        _currentHints = []; // reset hints per puzzle
      } else {
        await _completeSession();
      }

      notifyListeners();
    }

    return isCorrect;
  }

  double get _difficultyMultiplier {
    switch (_activeMission?.difficulty) {
      case 'easy':
        return 1.0;
      case 'hard':
        return 2.0;
      default:
        return 1.5;
    }
  }

  Future<void> _completeSession() async {
    if (_activeSession == null) return;

    _activeSession = _activeSession!.copyWith(
      isComplete: true,
      completionTime: DateTime.now().toIso8601String(),
    );
    await _db.updateSession(_activeSession!);
    await _unlockNextMission();
    await _checkAchievements();
    await refreshStats();
    _currentClues = await _db.getCluesForMission(_activeMission!.id!);
    _missionHintHistory = await _db.getHintRecordsForMission(_activeMission!.id!);
    _sessions = await _db.getSessionsForMission(_activeMission!.id!);
    notifyListeners();
  }

  // ── Hints ──

  /// Uses a hint for the current puzzle and records it.
  Future<String?> useHint() async {
    final puzzle = currentPuzzle;
    if (puzzle == null || _activeSession == null) return null;

    final hintText = puzzle.hint;

    final record = HintRecord(
      sessionId: _activeSession!.id!,
      puzzleId: puzzle.id!,
      hintText: hintText,
      timestamp: DateTime.now().toIso8601String(),
    );
    await _db.insertHintRecord(record);

    _activeSession = _activeSession!.copyWith(
      hintsUsed: _activeSession!.hintsUsed + 1,
    );
    await _db.updateSession(_activeSession!);

    _currentHints = await _db.getHintRecordsForSession(_activeSession!.id!);
    notifyListeners();

    return hintText;
  }

  // ── Achievements ──

  Future<void> refreshAchievements() async {
    _achievements = await _db.getAchievements();
    notifyListeners();
  }

  Future<void> _checkAchievements() async {
    if (_activeSession == null) return;

    final allSessions = await _db.getAllCompletedSessions();

    // First Steps — first puzzle solved anywhere
    await _tryUnlock(0, allSessions.any((s) => s.puzzlesSolved > 0));

    // Speed Demon — any mission under 3 minutes
    await _tryUnlock(
      1,
      allSessions.any((s) => s.elapsed.inMinutes < 3),
    );

    // No Help Needed — completed a mission with 0 hints
    await _tryUnlock(
      2,
      allSessions.any((s) => s.isComplete && s.hintsUsed == 0),
    );

    // Puzzle Master — completed all missions
    final completedMissionIds =
        allSessions.where((s) => s.isComplete).map((s) => s.missionId).toSet();
    await _tryUnlock(3, completedMissionIds.length >= _missions.length);

    // Hint Collector — used 10+ hints total
    final totalHints =
        allSessions.fold<int>(0, (sum, s) => sum + s.hintsUsed);
    await _tryUnlock(4, totalHints >= 10);

    // Persistent — 5+ completed sessions
    await _tryUnlock(5, allSessions.length >= 5);

    // Perfectionist — 100% score (solved all puzzles, 0 hints)
    await _tryUnlock(
      6,
      allSessions.any(
        (s) =>
            s.isComplete &&
            s.puzzlesSolved == s.totalPuzzles &&
            s.hintsUsed == 0,
      ),
    );

    // Night Owl — completed after 10 PM
    await _tryUnlock(
      7,
      allSessions.any((s) {
        if (!s.isComplete || s.completionTime == null) return false;
        return DateTime.parse(s.completionTime!).hour >= 22;
      }),
    );

    await refreshAchievements();
  }

  /// Unlocks achievement at [index] if [condition] is true and not yet unlocked.
  Future<void> _tryUnlock(int index, bool condition) async {
    if (!condition || index >= _achievements.length) return;
    if (_achievements[index].isUnlocked) return;
    await _db.unlockAchievement(_achievements[index].id!);
  }

  // ── Statistics ──

  Future<void> refreshStats() async {
    _stats = await _db.getOverallStats();
    notifyListeners();
  }

  // ── Leaderboard ──

  Future<List<GameSession>> getLeaderboard() async {
    return await _db.getAllCompletedSessions();
  }

  // ── Cleanup ──

  Future<void> deleteSession(int id) async {
    await _db.deleteSession(id);
    await refreshStats();
    if (_activeMission != null) {
      _sessions = await _db.getSessionsForMission(_activeMission!.id!);
    }
    notifyListeners();
  }
}
