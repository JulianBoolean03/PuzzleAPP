/// Records when a hint was used during a game session.
///
/// Links a specific puzzle to the session in which the
/// hint was consumed, along with the generated hint text.
class HintRecord {
  final int? id;
  final int sessionId;
  final int puzzleId;
  final String hintText;
  final String timestamp; // ISO 8601

  const HintRecord({
    this.id,
    required this.sessionId,
    required this.puzzleId,
    required this.hintText,
    required this.timestamp,
  });

  factory HintRecord.fromMap(Map<String, dynamic> map) {
    return HintRecord(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      puzzleId: map['puzzle_id'] as int,
      hintText: map['hint_text'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'puzzle_id': puzzleId,
      'hint_text': hintText,
      'timestamp': timestamp,
    };
  }
}
