/// Represents a single play-through of a mission.
///
/// Tracks timing, score, and completion state so that
/// players can compare performance across attempts.
class GameSession {
  final int? id;
  final int missionId;
  final String startTime; // ISO 8601
  final String? completionTime; // ISO 8601, null if in-progress
  final int score;
  final int hintsUsed;
  final int puzzlesSolved;
  final int totalPuzzles;
  final bool isComplete;

  const GameSession({
    this.id,
    required this.missionId,
    required this.startTime,
    this.completionTime,
    this.score = 0,
    this.hintsUsed = 0,
    this.puzzlesSolved = 0,
    this.totalPuzzles = 0,
    this.isComplete = false,
  });

  /// Elapsed duration from start to completion (or now if still running).
  Duration get elapsed {
    final start = DateTime.parse(startTime);
    final end = completionTime != null
        ? DateTime.parse(completionTime!)
        : DateTime.now();
    return end.difference(start);
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as int?,
      missionId: map['mission_id'] as int,
      startTime: map['start_time'] as String,
      completionTime: map['completion_time'] as String?,
      score: map['score'] as int,
      hintsUsed: map['hints_used'] as int,
      puzzlesSolved: map['puzzles_solved'] as int,
      totalPuzzles: map['total_puzzles'] as int,
      isComplete: (map['is_complete'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mission_id': missionId,
      'start_time': startTime,
      'completion_time': completionTime,
      'score': score,
      'hints_used': hintsUsed,
      'puzzles_solved': puzzlesSolved,
      'total_puzzles': totalPuzzles,
      'is_complete': isComplete ? 1 : 0,
    };
  }

  GameSession copyWith({
    int? id,
    int? missionId,
    String? startTime,
    String? completionTime,
    int? score,
    int? hintsUsed,
    int? puzzlesSolved,
    int? totalPuzzles,
    bool? isComplete,
  }) {
    return GameSession(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      score: score ?? this.score,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      totalPuzzles: totalPuzzles ?? this.totalPuzzles,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
