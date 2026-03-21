import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../services/export_service.dart';
import '../services/preferences_service.dart';

/// Lets the player adjust theme, difficulty, hint timing, font size, etc.
///
/// All changes are persisted via SharedPreferences so they survive restarts.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _difficulty;
  late int _hintDelay;
  late bool _timerEnabled;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _difficulty = prefs.difficulty;
    _hintDelay = prefs.hintDelaySeconds;
    _timerEnabled = prefs.timerEnabled;
    _soundEnabled = prefs.soundEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final prefs = context.read<PreferencesService>();

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Settings'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Appearance ──
                _SectionHeader(title: 'Appearance'),
                const SizedBox(height: 8),

                // Theme mode
                Card(
                  child: ListTile(
                    leading: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : themeProvider.themeMode == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.brightness_auto,
                    ),
                    title: const Text('Theme'),
                    subtitle: Text(_themeModeLabel(themeProvider.themeMode)),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (selected) {
                        themeProvider.setThemeMode(selected.first);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Font scale slider
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.text_fields),
                            const SizedBox(width: 12),
                            Text(
                              'Font Size',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${(themeProvider.fontScale * 100).round()}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: themeProvider.fontScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          label: '${(themeProvider.fontScale * 100).round()}%',
                          onChanged: (value) {
                            themeProvider.setFontScale(value);
                          },
                        ),
                        // Preview text
                        Text(
                          'Preview: The quick brown fox jumps over the lazy dog.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14 * themeProvider.fontScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Gameplay ──
                _SectionHeader(title: 'Gameplay'),
                const SizedBox(height: 8),

                // Default difficulty
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text('Default Difficulty'),
                    subtitle: Text(_difficulty.toUpperCase()),
                    trailing: DropdownButton<String>(
                      value: _difficulty,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _difficulty = value);
                        prefs.setDifficulty(value);
                      },
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Easy')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'hard', child: Text('Hard')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Timer toggle
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.timer),
                    title: const Text('Show Timer'),
                    subtitle: const Text('Display elapsed time during puzzles'),
                    value: _timerEnabled,
                    onChanged: (value) {
                      setState(() => _timerEnabled = value);
                      prefs.setTimerEnabled(value);
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Hint delay
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline),
                            const SizedBox(width: 12),
                            Text(
                              'Auto-Hint Delay',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${_hintDelay}s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How long before the app suggests using a hint',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        Slider(
                          value: _hintDelay.toDouble(),
                          min: 15,
                          max: 180,
                          divisions: 11,
                          label: '${_hintDelay}s',
                          onChanged: (value) {
                            setState(() => _hintDelay = value.round());
                            prefs.setHintDelaySeconds(value.round());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Sound toggle
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.volume_up),
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Play sounds for correct/wrong answers'),
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() => _soundEnabled = value);
                      prefs.setSoundEnabled(value);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // ── Data ──
                _SectionHeader(title: 'Data'),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.upload_file),
                        title: const Text('Export Progress'),
                        subtitle: const Text('Save your data as JSON'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _exportData(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Import Progress'),
                        subtitle: const Text('Load data from a JSON file'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _importData(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── About ──
                _SectionHeader(title: 'About'),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('StoryPath'),
                        subtitle: const Text('v1.0.0'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Team FlutterWarriors'),
                        subtitle: const Text('Julian Robinson & Harry Ahsan'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Mobile App Development'),
                        subtitle: const Text('Spring 2026 Project'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final path = await ExportService().exportData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to: $path')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final controller = TextEditingController();
    final filePath = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File path',
            hintText: '/path/to/storypath_export.json',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (filePath == null || filePath.isEmpty) return;

    try {
      final count = await ExportService().importData(filePath);
      if (!context.mounted) return;
      // Refresh stats after import
      context.read<GameProvider>().refreshStats();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $count sessions successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
