import 'package:flutter/material.dart';

enum GameGenre {
  postApocalypse('Постапокалипсис', Icons.shield),
  roguelike('Rogue-like', Icons.whatshot),
  simulator('Симулятор', Icons.agriculture),
  soulsLike('Souls-like', Icons.castle),
  platformer('Платформер', Icons.terrain),
  metroidvania('Метроидвания', Icons.bug_report),
  sandbox('Песочница', Icons.grid_view),
  shooter('Шутер', Icons.gps_fixed),
  other('Другое', Icons.videogame_asset);

  final String label;
  final IconData icon;

  const GameGenre(this.label, this.icon);
}

class Game {
  final String id;
  final String title;
  final String subtitle;
  final GameGenre genre;
  final String? description;

  final String color;
  final String coverLetter;

  const Game({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.genre,
    required this.color,
    required this.coverLetter,
    this.description,
  });

  Color get coverColor => Color(int.parse('FF$color', radix: 16));

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      genre: GameGenre.values.byName(json['genre'] as String),
      description: json['description'] as String?,
      color: json['color'] as String,
      coverLetter: json['coverLetter'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'genre': genre.name,
      'description': description ?? '',
      'color': color,
      'coverLetter': coverLetter,
    };
  }
}
