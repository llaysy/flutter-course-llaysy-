import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';

class GameCover extends StatelessWidget {
  const GameCover({super.key, required this.game, this.fontSize = 36});

  final Game game;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: game.coverColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          game.coverLetter,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
