import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/team.dart';

class GameSave {
  final String id;
  final String name;
  final DateTime saveDate;
  final List<SavedTeam> teams;
  final String? boardImagePath;

  GameSave({
    required this.id,
    required this.name,
    required this.saveDate,
    required this.teams,
    this.boardImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'saveDate': saveDate.toIso8601String(),
      'teams': teams.map((team) => team.toJson()).toList(),
      'boardImagePath': boardImagePath,
    };
  }

  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      id: json['id'],
      name: json['name'],
      saveDate: DateTime.parse(json['saveDate']),
      teams: (json['teams'] as List)
          .map((teamJson) => SavedTeam.fromJson(teamJson))
          .toList(),
      boardImagePath: json['boardImagePath'],
    );
  }
}

class SavedTeam {
  final int id;
  final String name;
  final int position;
  final String? imagePath;
  final int colorValue; // Store color as int

  SavedTeam({
    required this.id,
    required this.name,
    required this.position,
    this.imagePath,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'imagePath': imagePath,
      'colorValue': colorValue,
    };
  }

  factory SavedTeam.fromJson(Map<String, dynamic> json) {
    return SavedTeam(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      imagePath: json['imagePath'],
      colorValue: json['colorValue'],
    );
  }

  factory SavedTeam.fromTeam(Team team) {
    return SavedTeam(
      id: team.id,
      name: team.name,
      position: team.position,
      imagePath: team.imagePath,
      colorValue: team.color.value,
    );
  }
}

class SaveService {
  static const String _savesKey = 'game_saves';
  static const String _lastSaveKey = 'last_save_id';

  static Future<void> saveGame({
    required String name,
    required List<Team> teams,
    String? boardImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate unique ID for this save
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create game save object
    final gameSave = GameSave(
      id: id,
      name: name,
      saveDate: DateTime.now(),
      teams: teams.map((team) => SavedTeam.fromTeam(team)).toList(),
      boardImagePath: boardImagePath,
    );

    // Get existing saves
    final saves = await getAllSaves();
    saves.add(gameSave);

    // Save to preferences
    final savesJson = saves.map((save) => save.toJson()).toList();
    await prefs.setString(_savesKey, jsonEncode(savesJson));
    await prefs.setString(_lastSaveKey, id);
  }

  static Future<List<GameSave>> getAllSaves() async {
    final prefs = await SharedPreferences.getInstance();
    final savesString = prefs.getString(_savesKey);
    
    if (savesString == null) return [];
    
    try {
      final savesList = jsonDecode(savesString) as List;
      return savesList.map((saveJson) => GameSave.fromJson(saveJson)).toList();
    } catch (e) {
      print('Error loading saves: $e');
      return [];
    }
  }

  static Future<GameSave?> getLastSave() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSaveId = prefs.getString(_lastSaveKey);
    
    if (lastSaveId == null) return null;
    
    final saves = await getAllSaves();
    try {
      return saves.firstWhere((save) => save.id == lastSaveId);
    } catch (e) {
      return null;
    }
  }

  static Future<GameSave?> getSaveById(String id) async {
    final saves = await getAllSaves();
    try {
      return saves.firstWhere((save) => save.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteSave(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saves = await getAllSaves();
    
    saves.removeWhere((save) => save.id == id);
    
    final savesJson = saves.map((save) => save.toJson()).toList();
    await prefs.setString(_savesKey, jsonEncode(savesJson));
    
    // Clear last save if it was deleted
    final lastSaveId = prefs.getString(_lastSaveKey);
    if (lastSaveId == id) {
      await prefs.remove(_lastSaveKey);
    }
  }

  static Future<void> clearAllSaves() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savesKey);
    await prefs.remove(_lastSaveKey);
  }

  static String formatSaveDate(DateTime date) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  static Future<bool> hasSavedGames() async {
    final saves = await getAllSaves();
    return saves.isNotEmpty;
  }
} 