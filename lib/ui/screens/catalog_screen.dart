import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';
import '../widgets/game_card.dart';

/// Данные каталога — константа вне метода build.
const List<Game> _games = [
  Game(
    id: 1,
    title: 'The Last of Us Part I',
    subtitle: 'Naughty Dog · 2022',
    genre: GameGenre.postApocalypse,
    coverColor: Color(0xFF7B3F3F),
    coverLetter: 'T',
  ),
  Game(
    id: 2,
    title: 'The Last of Us Part II Remastered',
    subtitle: 'Naughty Dog · 2024',
    genre: GameGenre.postApocalypse,
    coverColor: Color(0xFF3F7B6B),
    coverLetter: 'T',
  ),
  Game(
    id: 3,
    title: 'Hades',
    subtitle: 'Supergiant Games · 2020',
    genre: GameGenre.roguelike,
    coverColor: Color(0xFF8B3A3A),
    coverLetter: 'H',
  ),
  Game(
    id: 4,
    title: 'Stardew Valley',
    subtitle: 'ConcernedApe · 2016',
    genre: GameGenre.simulator,
    coverColor: Color(0xFF4F8B3A),
    coverLetter: 'S',
  ),
  Game(
    id: 5,
    title: 'Elden Ring: самая долгая и сложная игра в истории серии souls-like',
    subtitle: 'FromSoftware · 2022',
    genre: GameGenre.soulsLike,
    coverColor: Color(0xFF4A4336),
    coverLetter: 'E',
  ),
  Game(
    id: 6,
    title: 'Celeste',
    subtitle: 'Maddy Makes Games · 2018',
    genre: GameGenre.platformer,
    coverColor: Color(0xFF3A5A8B),
    coverLetter: 'C',
  ),
  Game(
    id: 7,
    title: 'Hollow Knight',
    subtitle: 'Team Cherry · 2017',
    genre: GameGenre.metroidvania,
    coverColor: Color(0xFF2E2E3A),
    coverLetter: 'H',
  ),
  Game(
    id: 8,
    title: 'Minecraft',
    subtitle: 'Mojang · 2011',
    genre: GameGenre.sandbox,
    coverColor: Color(0xFF5B8B3A),
    coverLetter: 'M',
  ),
  Game(
    id: 9,
    title: 'Half-Life 2',
    subtitle: 'Valve · 2004',
    genre: GameGenre.shooter,
    coverColor: Color(0xFF8B7A3A),
    coverLetter: 'H',
  ),
  Game(
    id: 10,
    title: 'Dark Souls III',
    subtitle: 'FromSoftware · 2016',
    genre: GameGenre.soulsLike,
    coverColor: Color(0xFF3A3A4A),
    coverLetter: 'D',
  ),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = {};
  bool _onlyLiked = false;

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  void _toggleFilter() {
    setState(() {
      _onlyLiked = !_onlyLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Отфильтрованный список считаем здесь, отдельно не храним.
    final visibleGames = _onlyLiked
        ? _games.where((game) => _likedIds.contains(game.id)).toList()
        : _games;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text('Каталог игр'), centerTitle: false),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'В каталоге: ${_games.length} · '
                    'В избранном: ${_likedIds.length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _toggleFilter,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _onlyLiked
                          ? const Color(0xFFFFE3E3)
                          : Colors.transparent,
                    ),
                    icon: Icon(
                      _onlyLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    label: const Text('Только избранные'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visibleGames.isEmpty
                  ? const Center(child: Text('Ничего не нашлось'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: visibleGames.length,
                      itemBuilder: (context, index) {
                        final game = visibleGames[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GameCard(
                            game: game,
                            isLiked: _likedIds.contains(game.id),
                            onLikeTap: () => _toggleLike(game.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
