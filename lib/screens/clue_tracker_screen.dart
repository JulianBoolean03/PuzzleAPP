import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

/// Displays all clues found and hints used for the currently selected mission.
///
/// Split into two tabs so the player can review what they've discovered
/// and see which hints they needed during their sessions.
class ClueTrackerScreen extends StatelessWidget {
  const ClueTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clues & Hints'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Clues Found'),
              Tab(icon: Icon(Icons.lightbulb_outline), text: 'Hints Used'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CluesTab(),
            _HintsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Clues Tab ──

class _CluesTab extends StatelessWidget {
  const _CluesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final clues = gameProvider.currentClues;

    if (clues.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No clues discovered yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solve puzzles to uncover clues!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clues.length,
      itemBuilder: (context, index) {
        final clue = clues[index];
        final timestamp = DateTime.tryParse(clue.foundAt);
        final timeString = timestamp != null
            ? '${timestamp.month}/${timestamp.day} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
            : 'Unknown time';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clue number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Clue content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clue.clueText,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Found: $timeString',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Hints Tab ──

class _HintsTab extends StatelessWidget {
  const _HintsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final hints = gameProvider.missionHintHistory;

    if (hints.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No hints used yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try solving puzzles without hints for bonus points!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.error),
              const SizedBox(width: 8),
              Text(
                '${hints.length} hint${hints.length == 1 ? '' : 's'} used '
                '(-${hints.length * 25} points total)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Hint list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hints.length,
            itemBuilder: (context, index) {
              final hint = hints[index];
              final timestamp = DateTime.tryParse(hint.timestamp);
              final timeString = timestamp != null
                  ? '${timestamp.month}/${timestamp.day} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                  : 'Unknown time';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hint.hintText,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Used: $timeString  •  -25 pts',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
