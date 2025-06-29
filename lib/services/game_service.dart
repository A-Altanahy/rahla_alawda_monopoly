import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/game_square.dart';
import '../models/team.dart';

class GameService extends ChangeNotifier {
  List<Team> _teams = [];
  List<GameSquare> _boardSquares = [];
  String? _gameMessage;

  GameService() {
    _initializeGame();
  }

  void _initializeGame() {
    // Initialize teams
    _teams = [
      Team(
        id: 0,
        name: "الفريق الأحمر",
        icon: Icons.directions_walk,
        color: Colors.red,
      ),
      Team(
        id: 1,
        name: "الفريق الأزرق",
        icon: Icons.directions_run,
        color: Colors.blue,
      ),
      Team(
        id: 2,
        name: "الفريق الأخضر",
        icon: Icons.emoji_people,
        color: Colors.green,
      ),
      Team(
        id: 3,
        name: "الفريق الأصفر",
        icon: Icons.person,
        color: Colors.amber,
      ),
      Team(
        id: 4,
        name: "الفريق البنفسجي",
        icon: Icons.accessibility,
        color: Colors.purple,
      ),
      Team(
        id: 5,
        name: "الفريق البرتقالي",
        icon: Icons.sports_martial_arts,
        color: Colors.orange,
      ),
    ];

    // Create complete board squares list
    _boardSquares = [
      // Corner 1: Start (نقطة البداية)
      GameSquare(
        name: "نقطة البداية",
        type: "start",
        description: "نقطة البداية - اجمع 200 دك",
      ),

      // Bottom edge (right to left)
      GameSquare(
        name: "مكة",
        type: "city",
        price: 60,
        description: "المدينة المقدسة",
      ),
      GameSquare(
        name: "صندوق الفاتحين",
        type: "card",
        description: "اسحب بطاقة من صندوق الفاتحين",
      ),
      GameSquare(
        name: "المدينة",
        type: "city",
        price: 60,
        description: "المدينة المنورة",
      ),
      GameSquare(
        name: "كُلفة التقصير",
        type: "penalty",
        price: 200,
        description: "ادفع كلفة التقصير 200 دك",
      ),
      GameSquare(
        name: "محطة الغُزاة",
        type: "station",
        price: 200,
        description: "محطة سكة حديد",
      ),
      GameSquare(
        name: "دمشق",
        type: "city",
        price: 100,
        description: "الشام الشريف",
      ),
      GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
      GameSquare(name: "حلب", type: "city", price: 100, description: "الشهباء"),
      GameSquare(
        name: "حمص",
        type: "city",
        price: 120,
        description: "مدينة خالد بن الوليد",
      ),

      // Corner 2: Jail (السجن)
      GameSquare(
        name: "السجن",
        type: "jail",
        description: "مجرد زيارة أو محبوس",
      ),

      // Left edge (bottom to top)
      GameSquare(
        name: "البصرة",
        type: "city",
        price: 140,
        description: "فيحاء العراق",
      ),
      GameSquare(
        name: "قلعة الكرك",
        type: "utility",
        price: 150,
        description: "قلعة الكرك التاريخية",
      ),
      GameSquare(
        name: "الكوفة",
        type: "city",
        price: 140,
        description: "مدينة الإمام علي",
      ),
      GameSquare(
        name: "بغداد",
        type: "city",
        price: 160,
        description: "عاصمة الرشيد",
      ),
      GameSquare(
        name: "محطة الثبات",
        type: "station",
        price: 200,
        description: "محطة سكة حديد",
      ),
      GameSquare(
        name: "القاهرة",
        type: "city",
        price: 180,
        description: "أم الدنيا",
      ),
      GameSquare(
        name: "صندوق الفاتحين",
        type: "card",
        description: "اسحب بطاقة من صندوق الفاتحين",
      ),
      GameSquare(
        name: "الاسكندرية",
        type: "city",
        price: 180,
        description: "عروس البحر المتوسط",
      ),
      GameSquare(
        name: "المنصورة",
        type: "city",
        price: 200,
        description: "المنصورة المجيدة",
      ),

      // Corner 3: Free Parking (دار الضيافة)
      GameSquare(
        name: "دار الضيافة",
        type: "rest",
        description: "استراحة مجانية",
      ),

      // Top edge (left to right)
      GameSquare(
        name: "فاس",
        type: "city",
        price: 220,
        description: "مدينة فاس العتيقة",
      ),
      GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
      GameSquare(
        name: "القيروان",
        type: "city",
        price: 220,
        description: "رابعة الحرمين الشريفين",
      ),
      GameSquare(
        name: "تلمسان",
        type: "city",
        price: 240,
        description: "لؤلؤة المغرب العربي",
      ),
      GameSquare(
        name: "محطة الرباط",
        type: "station",
        price: 200,
        description: "محطة سكة حديد",
      ),
      GameSquare(
        name: "قرطبة",
        type: "city",
        price: 260,
        description: "عاصمة الأندلس",
      ),
      GameSquare(
        name: "إشبيلية",
        type: "city",
        price: 260,
        description: "مدينة إشبيلية الأندلسية",
      ),
      GameSquare(
        name: "قلعة حلب",
        type: "utility",
        price: 150,
        description: "قلعة حلب التاريخية",
      ),
      GameSquare(
        name: "غرناطة",
        type: "city",
        price: 280,
        description: "آخر معاقل المسلمين في الأندلس",
      ),

      // Corner 4: Go to Jail (اذهب إلى السجن)
      GameSquare(
        name: "اذهب إلى السجن",
        type: "penalty",
        description: "اذهب مباشرة إلى السجن",
      ),

      // Right edge (top to bottom)
      GameSquare(
        name: "إسطنبول",
        type: "city",
        price: 300,
        description: "عاصمة الخلافة العثمانية",
      ),
      GameSquare(
        name: "بخارى",
        type: "city",
        price: 300,
        description: "مدينة بخارى التاريخية",
      ),
      GameSquare(
        name: "صندوق الفاتحين",
        type: "card",
        description: "اسحب بطاقة من صندوق الفاتحين",
      ),
      GameSquare(
        name: "سمرقند",
        type: "city",
        price: 320,
        description: "جوهرة طريق الحرير",
      ),
      GameSquare(
        name: "محطة النصر",
        type: "station",
        price: 200,
        description: "محطة سكة حديد",
      ),
      GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
      GameSquare(
        name: "غزة",
        type: "city",
        price: 350,
        description: "مدينة غزة الصامدة",
      ),
      GameSquare(
        name: "كلفة التقصير",
        type: "penalty",
        price: 100,
        description: "ادفع كلفة التقصير 100 دك",
      ),
      GameSquare(
        name: "القدس",
        type: "city",
        price: 400,
        description: "أولى القبلتين وثالث الحرمين الشريفين",
      ),
    ];

    // Debug prints
    print('GameService initialized');
    print('Teams count: ${_teams.length}');
    print('Board squares count: ${_boardSquares.length}');
    if (_boardSquares.isNotEmpty) {
      print('First square: ${_boardSquares[0].name}');
      print('Last square: ${_boardSquares.last.name}');
    }
  }

  List<Team> get teams => _teams;
  List<GameSquare> get boardSquares => _boardSquares;
  String? get gameMessage => _gameMessage;
  int get boardSize => _boardSquares.length;

  void moveTeam(int teamId, int steps) {
    if (teamId < 0 || teamId >= _teams.length) return;
    if (_boardSquares.isEmpty) return;

    final team = _teams[teamId];
    final oldPosition = team.position;

    team.moveBy(steps, boardSize);

    final newSquare = _boardSquares[team.position];
    String message =
        "${team.name} انتقل من ${_boardSquares[oldPosition].name} إلى ${newSquare.name}";

    if (newSquare.price != null) {
      message += " - السعر: ${newSquare.price} دك";
    }

    _gameMessage = message;
    notifyListeners();
  }

  void updateTeamImage(int teamId, String? imagePath) {
    if (teamId >= 0 && teamId < _teams.length) {
      _teams[teamId].imagePath = imagePath;
      notifyListeners();
    }
  }

  /// تحديث صورة الفريق مع حذف الصورة القديمة
  Future<bool> updateTeamImageWithCleanup(int teamId, String? newImagePath) async {
    if (teamId < 0 || teamId >= _teams.length) return false;
    
    try {
      // حذف الصورة القديمة إذا كانت موجودة
      final oldImagePath = _teams[teamId].imagePath;
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      
      // تحديث مسار الصورة الجديد
      _teams[teamId].imagePath = newImagePath;
      notifyListeners();
      return true;
    } catch (e) {
      print('خطأ في تحديث صورة الفريق: $e');
      return false;
    }
  }

  /// التحقق من وجود صورة مخصصة للفريق
  bool hasCustomImage(int teamId) {
    if (teamId < 0 || teamId >= _teams.length) return false;
    return _teams[teamId].imagePath != null;
  }

  void updateTeamName(int teamId, String newName) {
    if (teamId >= 0 && teamId < _teams.length && newName.isNotEmpty) {
      _teams[teamId].name = newName;
      notifyListeners();
    }
  }

  void resetGame() {
    for (var team in _teams) {
      team.position = 0;
    }
    _gameMessage = "تم إعادة تعيين اللعبة";
    notifyListeners();
  }

  Team getTeam(int teamId) {
    return _teams[teamId];
  }

  GameSquare getSquare(int position) {
    if (position < 0 || position >= _boardSquares.length)
      return _boardSquares[0];
    return _boardSquares[position];
  }

  List<Team> getTeamsAtPosition(int position) {
    return _teams.where((team) => team.position == position).toList();
  }

  void clearMessage() {
    _gameMessage = null;
    notifyListeners();
  }
}
