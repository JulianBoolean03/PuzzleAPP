/// Represents a puzzle mission containing multiple puzzles.
///
/// Each mission has a difficulty level and can contain
/// multiple sequential puzzles that players must solve.
class Mission {
  final int? id;
  final String title;
  final String description;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String storyIntro;
  final String storyConclusion;
  final bool isUnlocked;

  const Mission({
    this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.storyIntro,
    required this.storyConclusion,
    this.isUnlocked = false,
  });

  /// Creates a [Mission] from a database row map.
  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      storyIntro: map['story_intro'] as String,
      storyConclusion: map['story_conclusion'] as String,
      isUnlocked: (map['is_unlocked'] as int) == 1,
    );
  }

  /// Converts this mission to a map suitable for database insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'story_intro': storyIntro,
      'story_conclusion': storyConclusion,
      'is_unlocked': isUnlocked ? 1 : 0,
    };
  }

  Mission copyWith({
    int? id,
    String? title,
    String? description,
    String? difficulty,
    String? storyIntro,
    String? storyConclusion,
    bool? isUnlocked,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      storyIntro: storyIntro ?? this.storyIntro,
      storyConclusion: storyConclusion ?? this.storyConclusion,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
