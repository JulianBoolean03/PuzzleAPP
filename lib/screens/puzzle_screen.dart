import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/preferences_service.dart';

/// The core gameplay screen where players solve puzzles sequentially.
///
/// Features a live timer, answer input with validation, hint usage,
/// progress indicator, and animated feedback on correct/wrong answers.
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  final _answerController = TextEditingController();
  final _answerFocusNode = FocusNode();

  Timer? _timer;
  int _elapsedSeconds = 0;
  int _puzzleStartSeconds = 0;
  bool _showHint = false;
  bool _isWrongAnswer = false;
  bool _isCorrectAnswer = false;
  String? _currentHintText;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Shake animation for wrong answers
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Scale animation for correct answers
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
      _checkAutoHint();
    });
  }

  /// Checks if the player has been stuck long enough to trigger auto-hint.
  void _checkAutoHint() {
    if (_showHint || _currentHintText != null) return;
    final prefs = context.read<PreferencesService>();
    final delay = prefs.hintDelaySeconds;
    final stuckTime = _elapsedSeconds - _puzzleStartSeconds;

    if (stuckTime >= delay) {
      setState(() {
        _showHint = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final gameProvider = context.read<GameProvider>();
    final correct = await gameProvider.submitAnswer(answer);

    if (!mounted) return;

    if (correct) {
      setState(() {
        _isCorrectAnswer = true;
        _isWrongAnswer = false;
        _showHint = false;
        _currentHintText = null;
      });
      _successController.forward(from: 0);

      // Check if mission is complete
      if (gameProvider.activeSession?.isComplete == true) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        _showCompletionDialog();
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        setState(() {
          _isCorrectAnswer = false;
          _answerController.clear();
          _puzzleStartSeconds = _elapsedSeconds;
        });
      }
    } else {
      setState(() {
        _isWrongAnswer = true;
        _isCorrectAnswer = false;
      });
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _isWrongAnswer = false);
    }
  }

  Future<void> _requestHint() async {
    final gameProvider = context.read<GameProvider>();
    final hint = await gameProvider.useHint();
    if (hint != null && mounted) {
      setState(() {
        _currentHintText = hint;
        _showHint = false; // dismiss the auto-hint prompt
      });
    }
  }

  void _showCompletionDialog() {
    final gameProvider = context.read<GameProvider>();
    final session = gameProvider.activeSession;
    final mission = gameProvider.activeMission;

    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              const Text('Mission Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mission != null) ...[
                Text(
                  mission.storyConclusion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
              ],
              _CompletionStat(
                icon: Icons.star,
                label: 'Score',
                value: '${session?.score ?? 0}',
              ),
              _CompletionStat(
                icon: Icons.timer,
                label: 'Time',
                value: _formattedTime,
              ),
              _CompletionStat(
                icon: Icons.lightbulb,
                label: 'Hints Used',
                value: '${session?.hintsUsed ?? 0}',
              ),
              _CompletionStat(
                icon: Icons.extension,
                label: 'Puzzles Solved',
                value: '${session?.puzzlesSolved ?? 0}/${session?.totalPuzzles ?? 0}',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // back to mission detail
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameProvider = context.watch<GameProvider>();
    final puzzle = gameProvider.currentPuzzle;
    final puzzleIndex = gameProvider.currentPuzzleIndex;
    final totalPuzzles = gameProvider.currentPuzzles.length;
    final prefs = context.read<PreferencesService>();

    if (puzzle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puzzle Challenge')),
        body: const Center(child: Text('No puzzles available.')),
      );
    }

    final progress = totalPuzzles > 0 ? (puzzleIndex + 1) / totalPuzzles : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle ${puzzleIndex + 1} of $totalPuzzles'),
        actions: [
          if (prefs.timerEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formattedTime,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Puzzle type badge
                  Chip(
                    avatar: Icon(_puzzleTypeIcon(puzzle.puzzleType), size: 16),
                    label: Text(puzzle.puzzleType.toUpperCase()),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 16),

                  // Story content / flavor text
                  Card(
                    color: colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              puzzle.content,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question
                  Text(
                    puzzle.question,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Answer input
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final offset =
                          _shakeController.isAnimating
                              ? _shakeAnimation.value *
                                  ((_shakeController.value * 10).toInt().isEven
                                      ? 1
                                      : -1)
                              : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: TextField(
                      controller: _answerController,
                      focusNode: _answerFocusNode,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _submitAnswer(),
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Type your answer here...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit),
                        suffixIcon: _isCorrectAnswer
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : _isWrongAnswer
                                ? const Icon(Icons.cancel, color: Colors.red)
                                : null,
                        errorText: _isWrongAnswer ? 'Incorrect — try again!' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  ScaleTransition(
                    scale: _successScale,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitAnswer,
                        icon: Icon(
                          _isCorrectAnswer ? Icons.check : Icons.send,
                        ),
                        label: Text(
                          _isCorrectAnswer ? 'Correct!' : 'Submit Answer',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor:
                              _isCorrectAnswer ? Colors.green : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hint button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _currentHintText != null ? null : _requestHint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: Text(
                        _currentHintText != null
                            ? 'Hint Used'
                            : 'Use Hint (-25 pts)',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),

                  // Auto-hint prompt
                  if (_showHint && _currentHintText == null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Stuck? Tap "Use Hint" for a nudge in the right direction.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Display the hint
                  if (_currentHintText != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hint',
                                    style:
                                        theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentHintText!,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _puzzleTypeIcon(String type) {
    switch (type) {
      case 'riddle':
        return Icons.psychology;
      case 'cipher':
        return Icons.lock;
      case 'logic':
        return Icons.calculate;
      case 'pattern':
        return Icons.grid_on;
      default:
        return Icons.extension;
    }
  }
}

/// Small row used in the completion dialog to show a stat.
class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompletionStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
