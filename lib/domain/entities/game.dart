import 'package:flutter/material.dart';

/// Жанр игры (категория каталога).
enum GameGenre {
  postApocalypse('Постапокалипсис', Icons.shield),
  roguelike('Rogue-like', Icons.whatshot),
  simulator('Симулятор', Icons.agriculture),
  soulsLike('Souls-like', Icons.castle),
  platformer('Платформер', Icons.terrain),
  metroidvania('Метроидвания', Icons.bug_report),
  sandbox('Песочница', Icons.grid_view),
  shooter('Шутер', Icons.gps_fixed);

  final String label;
  final IconData icon;

  const GameGenre(this.label, this.icon);
}

/// Один элемент каталога — игра.
class Game {
  final int id;
  final String title;
  final String subtitle;
  final GameGenre genre;
  final String? description;
  final Color coverColor;
  final String coverLetter;

  const Game({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.genre,
    required this.coverColor,
    required this.coverLetter,
    this.description,
  });
}
