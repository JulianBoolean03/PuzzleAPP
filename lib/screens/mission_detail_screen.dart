import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mission.dart';
import '../providers/game_provider.dart';
import 'clue_tracker_screen.dart';
import 'puzzle_screen.dart';

/// Shows mission details, story intro, and past session history.
///
/// The player can start a new game session from this screen,
/// which navigates into the [PuzzleScreen].
class MissionDetailScreen extends StatelessWidget {
  final Mission mission;

  const MissionDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final sessions = gameProvider.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(mission.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'View Clues & Hints',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ClueTrackerScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        final offsetTween = Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOut));
                        final opacityTween = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeIn));

                        return SlideTransition(
                          position: animation.drive(offsetTween),
                          child: FadeTransition(
                            opacity: animation.drive(opacityTween),
                            child: child,
                          ),
                        );
                      },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty badge
            Chip(
              avatar: Icon(_difficultyIcon(mission.difficulty), size: 18),
              label: Text(
                mission.difficulty.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _difficultyColor(
                mission.difficulty,
                colorScheme,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(mission.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),

            // Story intro card
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: colorScheme.secondaryContainer,
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Story Introduction',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      mission.storyIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Past sessions
            if (sessions.isNotEmpty) ...[
              Text(
                'Past Sessions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...sessions.take(5).map((session) {
                final duration = session.elapsed;
                final minutes = duration.inMinutes;
                final seconds = duration.inSeconds % 60;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      session.isComplete ? Icons.check_circle : Icons.timelapse,
                      color: session.isComplete
                          ? Colors.green
                          : colorScheme.outline,
                    ),
                    title: Text(
                      session.isComplete ? 'Completed' : 'In Progress',
                    ),
                    subtitle: Text(
                      'Score: ${session.score} · '
                      'Time: ${minutes}m ${seconds}s · '
                      'Hints: ${session.hintsUsed}',
                    ),
                    trailing: Text(
                      '${session.puzzlesSolved}/${session.totalPuzzles}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _startMission(context),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              sessions.isEmpty ? 'Begin Mission' : 'Play Again',
              style: const TextStyle(fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startMission(BuildContext context) async {
    final gameProvider = context.read<GameProvider>();
    await gameProvider.startSession();

    if (!context.mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PuzzleScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetTween = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          final opacityTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn));

          return SlideTransition(
            position: animation.drive(offsetTween),
            child: FadeTransition(
              opacity: animation.drive(opacityTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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

  Color _difficultyColor(String difficulty, ColorScheme cs) {
    switch (difficulty) {
      case 'easy':
        return Colors.green.shade100;
      case 'hard':
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100;
    }
  }
}
