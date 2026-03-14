import '../models/mission.dart';
import '../models/puzzle.dart';
import '../models/achievement.dart';
import 'database_helper.dart';

/// Populates the database with initial missions, puzzles, and achievements
/// on first launch. Checks for existing data to avoid duplicates.
class SeedData {
  final DatabaseHelper _db;

  SeedData(this._db);

  Future<void> initialize() async {
    final existing = await _db.getMissions();
    if (existing.isNotEmpty) return; // already seeded

    await _seedMissions();
    await _seedAchievements();
  }

  Future<void> _seedMissions() async {
    // ── Mission 1: The Forgotten Laboratory ──
    await _db.insertMission(const Mission(
      title: 'The Forgotten Laboratory',
      description:
          'A hidden lab beneath the university has been sealed for decades. '
          'Crack the codes left behind by a rogue scientist to escape.',
      difficulty: 'easy',
      storyIntro:
          'You stumble upon a rusted door behind the library basement shelves. '
          'Inside, flickering fluorescent lights reveal dusty beakers and a '
          'locked terminal blinking: "AUTHORIZATION REQUIRED."',
      storyConclusion:
          'The final lock clicks open. Daylight floods in as the emergency exit '
          'swings wide. You clutch the scientist\'s journal—proof of experiments '
          'the university tried to bury. The truth is yours now.',
      isUnlocked: true,
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 1,
      orderIndex: 0,
      content:
          'A periodic table poster hangs on the wall. Several elements are '
          'circled in red marker: Hydrogen, Einsteinium, Lithium, Phosphorus.',
      question: 'What word do the circled element symbols spell?',
      answer: 'HELP',
      hint: 'Write down just the chemical symbol for each circled element.',
      puzzleType: 'cipher',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 1,
      orderIndex: 1,
      content:
          'The terminal screen reads: "I speak without a mouth and hear '
          'without ears. I have no body, but I come alive with wind."',
      question: 'What am I?',
      answer: 'ECHO',
      hint: 'Think about sounds that repeat in empty spaces.',
      puzzleType: 'riddle',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 1,
      orderIndex: 2,
      content:
          'A keypad on the exit door shows: 2, 4, 8, 16, ___. '
          'Enter the next number to unlock.',
      question: 'What is the next number in the sequence?',
      answer: '32',
      hint: 'Each number is multiplied by the same value.',
      puzzleType: 'pattern',
    ));

    // ── Mission 2: Midnight at the Museum ──
    await _db.insertMission(const Mission(
      title: 'Midnight at the Museum',
      description:
          'The city museum locks down at midnight with you inside. '
          'Navigate the exhibits and solve the curator\'s riddles to escape '
          'before the alarm triggers at dawn.',
      difficulty: 'medium',
      storyIntro:
          'The last security guard waves goodnight. You duck behind the '
          'Egyptian sarcophagus just as the heavy steel doors seal shut. '
          'A note falls from the mummy\'s hand: "Solve or stay forever."',
      storyConclusion:
          'The rooftop hatch swings open to a pink sunrise. Below, the '
          'museum sleeps peacefully, unaware that its deepest secrets have '
          'been unraveled by a curious mind.',
      isUnlocked: false,
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 2,
      orderIndex: 0,
      content:
          'A Roman numeral clock on the wall has its hands removed. '
          'Beneath it, a plaque reads: "The king\'s number minus the '
          'baker\'s dozen."',
      question: 'What number does the plaque describe?',
      answer: '7',
      hint: 'A king in cards is often associated with 20. A baker\'s dozen is 13.',
      puzzleType: 'logic',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 2,
      orderIndex: 1,
      content:
          'In the geology wing, five colored gemstones sit on pedestals. '
          'A sign reads: "I am not red, not blue, not yellow, not green. '
          'I am the color of royalty."',
      question: 'Which color gemstone should you pick up?',
      answer: 'PURPLE',
      hint: 'Think about what color has historically represented kings and queens.',
      puzzleType: 'riddle',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 2,
      orderIndex: 2,
      content:
          'A painting of a compass rose has letters at each cardinal direction: '
          'N=S, E=A, S=F, W=E. The frame is engraved: "Read me like the sun."',
      question: 'Reading the letters in the direction the sun travels, what word do you get?',
      answer: 'SAFE',
      hint: 'The sun rises in the East and moves clockwise: E → S → W → N.',
      puzzleType: 'cipher',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 2,
      orderIndex: 3,
      content:
          'The final door has a combination lock. On the wall: '
          '"Fibonacci\'s fifth greeting."',
      question: 'What is the 5th Fibonacci number?',
      answer: '5',
      hint: 'The Fibonacci sequence starts: 1, 1, 2, 3, ...',
      puzzleType: 'pattern',
    ));

    // ── Mission 3: The Clocktower Conspiracy ──
    await _db.insertMission(const Mission(
      title: 'The Clocktower Conspiracy',
      description:
          'The old clocktower holds secrets about the city\'s founding. '
          'Decipher the watchmaker\'s puzzles before the bell tolls midnight.',
      difficulty: 'hard',
      storyIntro:
          'The brass gears grind overhead as you climb the spiral staircase. '
          'Each landing holds a locked door and a faded riddle pinned to the '
          'wall. The clock reads 11:00 PM—you have one hour.',
      storyConclusion:
          'As the final gear clicks into place, the clocktower chimes not '
          'midnight, but a melody—the city\'s forgotten anthem. The secret '
          'chamber opens, revealing the original city charter, signed by '
          'names history never recorded.',
      isUnlocked: false,
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 3,
      orderIndex: 0,
      content:
          'The first landing has a mirror with backwards text etched into it.',
      question: 'Decode this mirror text: "EMIT SI REWOP"',
      answer: 'POWER IS TIME',
      hint: 'Read the text from right to left, word by word.',
      puzzleType: 'cipher',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 3,
      orderIndex: 1,
      content:
          'A set of interlocking gears is jammed. The large gear has 24 teeth, '
          'the medium gear has 12 teeth. If the large gear turns once, how many '
          'times does the medium gear turn?',
      question: 'How many full rotations does the medium gear make?',
      answer: '2',
      hint: 'Divide the number of teeth on the large gear by the medium gear.',
      puzzleType: 'logic',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 3,
      orderIndex: 2,
      content:
          'A pendulum swings over four tiles labeled A=1, B=2, C=3, D=4. '
          'The note says: "Sum the consonants."',
      question: 'What is the sum of the values under the consonant letters?',
      answer: '9',
      hint: 'B, C, and D are consonants. A is a vowel.',
      puzzleType: 'logic',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 3,
      orderIndex: 3,
      content:
          'The watchmaker left a Caesar cipher on the wall: "WKLQN". '
          'The shift key is hidden in the clock: the hour hand points to 3.',
      question: 'Decrypt "WKLQN" with a shift of 3.',
      answer: 'THINK',
      hint: 'Shift each letter back by 3 positions in the alphabet.',
      puzzleType: 'cipher',
    ));

    await _db.insertPuzzle(const Puzzle(
      missionId: 3,
      orderIndex: 4,
      content:
          'The final chamber door has a riddle: "I have cities, but no houses. '
          'I have mountains, but no trees. I have water, but no fish. '
          'I have roads, but no cars."',
      question: 'What am I?',
      answer: 'MAP',
      hint: 'Think of something that represents the world without being the world.',
      puzzleType: 'riddle',
    ));
  }

  Future<void> _seedAchievements() async {
    const achievements = [
      Achievement(
        title: 'First Steps',
        description: 'Complete your first puzzle.',
        iconName: 'star',
      ),
      Achievement(
        title: 'Speed Demon',
        description: 'Complete a mission in under 3 minutes.',
        iconName: 'speed',
      ),
      Achievement(
        title: 'No Help Needed',
        description: 'Complete a mission without using any hints.',
        iconName: 'psychology',
      ),
      Achievement(
        title: 'Puzzle Master',
        description: 'Complete all missions.',
        iconName: 'emoji_events',
      ),
      Achievement(
        title: 'Hint Collector',
        description: 'Use 10 hints across all sessions.',
        iconName: 'lightbulb',
      ),
      Achievement(
        title: 'Persistent',
        description: 'Play 5 game sessions.',
        iconName: 'repeat',
      ),
      Achievement(
        title: 'Perfectionist',
        description: 'Score 100%% on any mission.',
        iconName: 'workspace_premium',
      ),
      Achievement(
        title: 'Night Owl',
        description: 'Complete a mission after 10 PM.',
        iconName: 'nightlight',
      ),
    ];

    for (final a in achievements) {
      await _db.insertAchievement(a);
    }
  }
}
