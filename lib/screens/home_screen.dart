import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mission.dart';
import '../providers/game_provider.dart';
import '../widgets/mission_card.dart';
import 'mission_detail_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';

/// Main hub of the application.
///
/// Shows the list of available missions and provides bottom navigation
/// to the leaderboard, achievements, and settings screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  final _screens = const <Widget>[
    _MissionsView(),
    LeaderboardScreen(),
    AchievementsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) {
          setState(() => _currentTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Displays the mission list with search and difficulty filter.
class _MissionsView extends StatefulWidget {
  const _MissionsView();

  @override
  State<_MissionsView> createState() => _MissionsViewState();
}

class _MissionsViewState extends State<_MissionsView> {
  String _searchQuery = '';
  String _difficultyFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();

    // Filter missions based on search and difficulty
    var missions = gameProvider.missions;
    if (_searchQuery.isNotEmpty) {
      missions = missions
          .where(
            (m) =>
                m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                m.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
    if (_difficultyFilter != 'all') {
      missions = missions
          .where((m) => m.difficulty == _difficultyFilter)
          .toList();
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              const Text('StoryPath'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh missions',
              onPressed: () => gameProvider.refreshMissions(),
            ),
          ],
        ),
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search missions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
        // Difficulty filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _difficultyFilter == 'all',
                    onTap: () => setState(() => _difficultyFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Easy',
                    selected: _difficultyFilter == 'easy',
                    onTap: () => setState(() => _difficultyFilter = 'easy'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Medium',
                    selected: _difficultyFilter == 'medium',
                    onTap: () => setState(() => _difficultyFilter = 'medium'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Hard',
                    selected: _difficultyFilter == 'hard',
                    onTap: () => setState(() => _difficultyFilter = 'hard'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Stats summary bar
        SliverToBoxAdapter(child: _StatsBar(stats: gameProvider.stats)),
        // Section header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Available Missions (${missions.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Mission list
        if (missions.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    'No missions found',
                    style: theme.textTheme.bodyLarge?.copyWith(
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
            sliver: SliverList.separated(
              itemCount: missions.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return MissionCard(
                  mission: mission,
                  onTap: mission.isUnlocked
                      ? () => _openMission(context, mission)
                      : null,
                );
              },
            ),
          ),
        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  void _openMission(BuildContext context, Mission mission) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.selectMission(mission);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MissionDetailScreen(mission: mission),
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
}

/// Compact stats row shown above the mission list.
class _StatsBar extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.play_circle,
                label: 'Sessions',
                value: '${stats['total_sessions'] ?? 0}',
              ),
              _StatItem(
                icon: Icons.extension,
                label: 'Solved',
                value: '${stats['total_puzzles_solved'] ?? 0}',
              ),
              _StatItem(
                icon: Icons.star,
                label: 'Best',
                value: '${stats['best_score'] ?? 0}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }
}
