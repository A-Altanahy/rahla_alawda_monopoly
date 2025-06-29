import 'package:flutter/material.dart';

class Team {
  final int id;
  String name;
  final IconData icon;
  final Color color;
  int position;
  String? imagePath;

  Team({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.position = 0,
    this.imagePath,
  });

  void moveBy(int steps, int boardSize) {
    position = ((position + steps) % boardSize + boardSize) % boardSize;
  }

  void moveTo(int newPosition) {
    position = newPosition;
  }
}

final List<Team> teams = [
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