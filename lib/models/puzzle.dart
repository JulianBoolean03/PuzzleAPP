/// Represents a single puzzle within a mission.
///
/// Puzzles are sequential challenges that the player must
/// answer correctly to progress through a mission.
class Puzzle {
  final int? id;
  final int missionId;
  final int orderIndex;
  final String content; // narrative/flavor text
  final String question;
  final String answer;
  final String hint;
  final String puzzleType; // 'riddle', 'cipher', 'logic', 'pattern'

  const Puzzle({
    this.id,
    required this.missionId,
    required this.orderIndex,
    required this.content,
    required this.question,
    required this.answer,
    required this.hint,
    required this.puzzleType,
  });

  factory Puzzle.fromMap(Map<String, dynamic> map) {
    return Puzzle(
      id: map['id'] as int?,
      missionId: map['mission_id'] as int,
      orderIndex: map['order_index'] as int,
      content: map['content'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      hint: map['hint'] as String,
      puzzleType: map['puzzle_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mission_id': missionId,
      'order_index': orderIndex,
      'content': content,
      'question': question,
      'answer': answer,
      'hint': hint,
      'puzzle_type': puzzleType,
    };
  }

  Puzzle copyWith({
    int? id,
    int? missionId,
    int? orderIndex,
    String? content,
    String? question,
    String? answer,
    String? hint,
    String? puzzleType,
  }) {
    return Puzzle(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      orderIndex: orderIndex ?? this.orderIndex,
      content: content ?? this.content,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      puzzleType: puzzleType ?? this.puzzleType,
    );
  }
}
