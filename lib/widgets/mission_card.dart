import 'package:flutter/material.dart';

import '../models/mission.dart';

/// A styled card representing a single mission in the list.
///
/// Shows the title, description preview, difficulty badge,
/// and a lock icon if the mission hasn't been unlocked yet.
class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;

  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = !mission.isUnlocked;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isLocked ? 0 : 2,
      color: isLocked
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mission icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLocked
                      ? colorScheme.outline.withValues(alpha: 0.15)
                      : _difficultyColor(mission.difficulty, colorScheme),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isLocked ? Icons.lock : _difficultyIcon(mission.difficulty),
                  color: isLocked
                      ? colorScheme.outline
                      : _difficultyIconColor(mission.difficulty),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked ? colorScheme.outline : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLocked
                            ? colorScheme.outline.withValues(alpha: 0.6)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Difficulty tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? colorScheme.outline.withValues(alpha: 0.1)
                            : _difficultyColor(mission.difficulty, colorScheme),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        mission.difficulty.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? colorScheme.outline
                              : _difficultyIconColor(mission.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              if (!isLocked)
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty, ColorScheme cs) {
    switch (difficulty) {
      case 'easy':
        return Colors.green.shade50;
      case 'hard':
        return Colors.red.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _difficultyIconColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green.shade700;
      case 'hard':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _difficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'hard':
        return Icons.whatshot;
      default:
        return Icons.trending_up;
    }
  }
}
