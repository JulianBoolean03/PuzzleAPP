import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_session.dart';
import '../providers/game_provider.dart';

/// Shows completed session history ranked by score, plus overall stats.
///
/// Players can see their best runs, compare times, and delete old sessions.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<GameSession> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final gameProvider = context.read<GameProvider>();
    final sessions = await gameProvider.getLeaderboard();
    if (!mounted) return;
    setState(() {
      _leaderboard = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final stats = gameProvider.stats;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Leaderboard'),
        ),

        // Stats cards row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.play_circle,
                    label: 'Total Games',
                    value: '${stats['total_sessions'] ?? 0}',
                    color: colorScheme.primaryContainer,
                    onColor: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    label: 'Best Score',
                    value: '${stats['best_score'] ?? 0}',
                    color: Colors.amber.shade100,
                    onColor: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.extension,
                    label: 'Puzzles Solved',
                    value: '${stats['total_puzzles_solved'] ?? 0}',
                    color: Colors.green.shade100,
                    onColor: Colors.green.shade900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.lightbulb,
                    label: 'Hints Used',
                    value: '${stats['total_hints'] ?? 0}',
                    color: Colors.orange.shade100,
                    onColor: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Session History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Leaderboard list
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_leaderboard.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard_outlined,
                      size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No completed sessions yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a mission to see your scores here!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final session = _leaderboard[index];
                return _LeaderboardTile(
                  rank: index + 1,
                  session: session,
                  missionTitle: _getMissionTitle(gameProvider, session.missionId),
                  onDelete: () => _deleteSession(session),
                );
              },
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  String _getMissionTitle(GameProvider provider, int missionId) {
    final mission = provider.missions.where((m) => m.id == missionId);
    if (mission.isEmpty) return 'Unknown Mission';
    return mission.first.title;
  }

  Future<void> _deleteSession(GameSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text(
          'This will permanently remove this session from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.deleteSession(session.id!);
      await _loadLeaderboard();
    }
  }
}

// ── Stat Card ──

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: onColor,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: onColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leaderboard Tile ──

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final GameSession session;
  final String missionTitle;
  final VoidCallback onDelete;

  const _LeaderboardTile({
    required this.rank,
    required this.session,
    required this.missionTitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = session.elapsed;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    // Top 3 get special colors
    Color? rankColor;
    IconData rankIcon = Icons.emoji_events;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
    } else {
      rankIcon = Icons.tag;
      rankColor = colorScheme.outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rank <= 3)
                Icon(rankIcon, color: rankColor, size: 24)
              else
                Text(
                  '#$rank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          missionTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Time: ${minutes}m ${seconds}s  •  Hints: ${session.hintsUsed}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.score}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'pts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Delete session',
            ),
          ],
        ),
      ),
    );
  }
}
