/// Represents an unlockable achievement earned by the player.
///
/// Achievements are awarded for milestones such as completing
/// missions without hints or finishing under a time threshold.
class Achievement {
  final int? id;
  final String title;
  final String description;
  final String iconName; // Material icon name
  final String? unlockedAt; // ISO 8601, null if still locked

  const Achievement({
    this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      iconName: map['icon_name'] as String,
      unlockedAt: map['unlocked_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'unlocked_at': unlockedAt,
    };
  }

  Achievement copyWith({
    int? id,
    String? title,
    String? description,
    String? iconName,
    String? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
