import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

/// Displays all achievements with locked/unlocked states.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final achievements = gameProvider.achievements;
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Achievements'),
        ),

        // Progress summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 32, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlocked of ${achievements.length} Unlocked',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: achievements.isEmpty
                                ? 0
                                : unlocked / achievements.length,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Achievement grid
        if (achievements.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No achievements available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isLocked = !achievement.isUnlocked;

                return Card(
                  color: isLocked
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : colorScheme.secondaryContainer,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showDetail(context, achievement.title,
                        achievement.description, isLocked),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLocked
                                ? Icons.lock
                                : _getIcon(achievement.iconName),
                            size: 36,
                            color: isLocked
                                ? colorScheme.outline
                                : colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? colorScheme.outline
                                  : colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLocked ? '???' : achievement.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isLocked
                                  ? colorScheme.outline
                                  : colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showDetail(
      BuildContext context, String title, String description, bool locked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(locked
            ? 'Keep playing to unlock this achievement!'
            : description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'star':
        return Icons.star;
      case 'speed':
        return Icons.speed;
      case 'psychology':
        return Icons.psychology;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'repeat':
        return Icons.repeat;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'nightlight':
        return Icons.nightlight;
      default:
        return Icons.star;
    }
  }
}
