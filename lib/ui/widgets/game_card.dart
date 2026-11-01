import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';
import 'game_cover.dart';
import 'like_button.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.isLiked,
    required this.onLikeTap,
    required this.onTap,
  });

  final Game game;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обложка: Stack из фона с буквой и сердечка поверх.
              SizedBox(
                width: 88,
                height: 110,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'cover-${game.id}',
                        child: GameCover(game: game),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: LikeButton(isLiked: isLiked, onTap: onLikeTap),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      game.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          game.genre.icon,
                          size: 14,
                          color: Colors.grey[700],
                        ),
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
                              game.genre.label,
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
        ),
      ),
    );
  }
}
