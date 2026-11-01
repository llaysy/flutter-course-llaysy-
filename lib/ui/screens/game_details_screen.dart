import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/catalog/catalog_bloc.dart';
import '../../bloc/catalog/catalog_event.dart';
import '../../bloc/catalog/catalog_state.dart';
import '../../domain/entities/game.dart';
import '../widgets/game_cover.dart';
import '../widgets/game_form_sheet.dart';
import '../widgets/like_button.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key, required this.gameId});

  final String gameId;

  Future<void> _confirmDelete(BuildContext context, Game game) async {
    final bloc = context.read<CatalogBloc>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить игру?'),
        content: Text('«${game.title}» будет удалена из каталога.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(CatalogGameDeleted(game.id));
      navigator.pop();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final game = state.gameById(gameId);
        if (game == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Игра больше не доступна')),
          );
        }
        final isLiked = state.likedIds.contains(game.id);
        final description = game.description;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            title: const Text('Детали'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Редактировать',
                onPressed: () => showGameFormSheet(context, initial: game),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Удалить',
                onPressed: () => _confirmDelete(context, game),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 230,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: 'cover-${game.id}',
                            child: GameCover(game: game, fontSize: 72),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: LikeButton(
                            isLiked: isLiked,
                            size: 26,
                            onTap: () => context.read<CatalogBloc>().add(
                              CatalogLikeToggled(game.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  game.subtitle,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(game.genre.icon, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(game.genre.label),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Описание',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  (description == null || description.isEmpty)
                      ? 'Описание не добавлено'
                      : description,
                ),
                if (game.createdAt != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Добавлено: ${_formatDate(game.createdAt!)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
