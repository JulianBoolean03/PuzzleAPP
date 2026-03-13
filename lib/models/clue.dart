/// Represents a clue discovered during a mission session.
///
/// Clues are narrative elements uncovered as the player
/// progresses through puzzles in a mission.
class Clue {
  final int? id;
  final int missionId;
  final String clueText;
  final String foundAt; // ISO 8601 timestamp

  const Clue({
    this.id,
    required this.missionId,
    required this.clueText,
    required this.foundAt,
  });

  factory Clue.fromMap(Map<String, dynamic> map) {
    return Clue(
      id: map['id'] as int?,
      missionId: map['mission_id'] as int,
      clueText: map['clue_text'] as String,
      foundAt: map['found_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mission_id': missionId,
      'clue_text': clueText,
      'found_at': foundAt,
    };
  }
}
