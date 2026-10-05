import 'package:flutter/material.dart';

void main() {
  runApp(const Hw2App());
}

class Hw2App extends StatelessWidget {
  const Hw2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(title: const Text('Каталог игр'), centerTitle: false),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GameCard(game: games[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Game {
  final String title;
  final String studioAndYear;
  final String genre;
  final IconData genreIcon;
  final Color coverColor;
  final String coverLetter;

  const Game({
    required this.title,
    required this.studioAndYear,
    required this.genre,
    required this.genreIcon,
    required this.coverColor,
    required this.coverLetter,
  });
}

final List<Game> games = [
  const Game(
    title: 'The Last of Us Part I',
    studioAndYear: 'Naughty Dog · 2022',
    genre: 'Постапокалипсис',
    genreIcon: Icons.shield,
    coverColor: Color(0xFF7B3F3F),
    coverLetter: 'T',
  ),
  const Game(
    title: 'The Last of Us Part II Remastered',
    studioAndYear: 'Naughty Dog · 2024',
    genre: 'Постапокалипсис',
    genreIcon: Icons.shield,
    coverColor: Color(0xFF3F7B6B),
    coverLetter: 'T',
  ),
  const Game(
    title: 'Hades',
    studioAndYear: 'Supergiant Games · 2020',
    genre: 'Rogue-like',
    genreIcon: Icons.whatshot,
    coverColor: Color(0xFF8B3A3A),
    coverLetter: 'H',
  ),
  const Game(
    title: 'Stardew Valley',
    studioAndYear: 'ConcernedApe · 2016',
    genre: 'Симулятор',
    genreIcon: Icons.agriculture,
    coverColor: Color(0xFF4F8B3A),
    coverLetter: 'S',
  ),
  const Game(
    title: 'Elden Ring: самая долгая и сложная игра в истории серии souls-like',
    studioAndYear: 'FromSoftware · 2022',
    genre: 'Souls-like',
    genreIcon: Icons.castle,
    coverColor: Color(0xFF4A4336),
    coverLetter: 'E',
  ),
  const Game(
    title: 'Celeste',
    studioAndYear: 'Maddy Makes Games · 2018',
    genre: 'Платформер',
    genreIcon: Icons.terrain,
    coverColor: Color(0xFF3A5A8B),
    coverLetter: 'C',
  ),
  const Game(
    title: 'Hollow Knight',
    studioAndYear: 'Team Cherry · 2017',
    genre: 'Метроидвания',
    genreIcon: Icons.bug_report,
    coverColor: Color(0xFF2E2E3A),
    coverLetter: 'H',
  ),
  const Game(
    title: 'Minecraft',
    studioAndYear: 'Mojang · 2011',
    genre: 'Песочница',
    genreIcon: Icons.grid_view,
    coverColor: Color(0xFF5B8B3A),
    coverLetter: 'M',
  ),
  const Game(
    title: 'Half-Life 2',
    studioAndYear: 'Valve · 2004',
    genre: 'Шутер',
    genreIcon: Icons.gps_fixed,
    coverColor: Color(0xFF8B7A3A),
    coverLetter: 'H',
  ),
  const Game(
    title: 'Dark Souls III',
    studioAndYear: 'FromSoftware · 2016',
    genre: 'Souls-like',
    genreIcon: Icons.castle,
    coverColor: Color(0xFF3A3A4A),
    coverLetter: 'D',
  ),
];

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 110,
                decoration: BoxDecoration(
                  color: game.coverColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  game.coverLetter,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.studioAndYear,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(game.genreIcon, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          game.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
