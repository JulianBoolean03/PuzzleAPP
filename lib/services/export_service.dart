import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/game_session.dart';
import '../models/clue.dart';
import 'database_helper.dart';

/// Handles exporting and importing game data as JSON files.
///
/// Exports sessions, clues, and achievements to the app's documents
/// directory. Import reads the same format back in.
class ExportService {
  final DatabaseHelper _db = DatabaseHelper();

  /// Exports all player data to a JSON file. Returns the file path.
  Future<String> exportData() async {
    final sessions = await _db.getAllCompletedSessions();
    final achievements = await _db.getAchievements();
    final missions = await _db.getMissions();

    // Gather clues for all missions
    final allClues = <Map<String, dynamic>>[];
    for (final mission in missions) {
      final clues = await _db.getCluesForMission(mission.id!);
      for (final clue in clues) {
        allClues.add(clue.toMap());
      }
    }

    final data = {
      'app': 'StoryPath',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'clues': allClues,
      'achievements': achievements.map((a) => a.toMap()).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/storypath_export.json');
    await file.writeAsString(jsonEncode(data));

    return file.path;
  }

  /// Imports data from a JSON file at the given path.
  /// Returns the number of sessions imported.
  Future<int> importData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    // Validate it's a StoryPath export
    if (data['app'] != 'StoryPath') {
      throw Exception('Not a valid StoryPath export file.');
    }

    int imported = 0;

    // Import sessions
    final sessionList = data['sessions'] as List<dynamic>? ?? [];
    for (final sessionMap in sessionList) {
      final map = Map<String, dynamic>.from(sessionMap);
      map.remove('id'); // let DB assign new IDs
      final session = GameSession.fromMap({
        ...map,
        'id': null,
      });
      await _db.insertSession(session);
      imported++;
    }

    // Import clues
    final clueList = data['clues'] as List<dynamic>? ?? [];
    for (final clueMap in clueList) {
      final map = Map<String, dynamic>.from(clueMap);
      map.remove('id');
      final clue = Clue.fromMap({
        ...map,
        'id': null,
      });
      await _db.insertClue(clue);
    }

    return imported;
  }
}
