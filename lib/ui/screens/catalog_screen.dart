import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/catalog/catalog_bloc.dart';
import '../../bloc/catalog/catalog_event.dart';
import '../../bloc/catalog/catalog_state.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/game_card.dart';
import '../widgets/game_form_sheet.dart';
import 'game_details_screen.dart';

//блок билдер вилидирует статус и рисует

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  void _openDetails(BuildContext context, String gameId) {
    final bloc = context.read<CatalogBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<CatalogBloc>.value(
          value: bloc,
          child: GameDetailsScreen(gameId: gameId),
        ),
      ),
    );
  }

  String _emptyText(CatalogState state) {
    if (state.games.isEmpty) {
      return 'Каталог пока пуст. Добавьте первую игру кнопкой «+».';
    }
    if (state.query.trim().isNotEmpty) {
      return 'Ничего не найдено по запросу «${state.query.trim()}»';
    }
    if (state.onlyLiked) return 'В избранном пока пусто';
    return 'Ничего не нашлось';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CatalogBloc, CatalogState>(
      listenWhen: (previous, current) =>
          previous.messageSeq != current.messageSeq && current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          title: const Text('Каталог игр'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Добавить игру',
              onPressed: () => showGameFormSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<CatalogBloc, CatalogState>(
            builder: (context, state) {
              switch (state.status) {
                case CatalogStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case CatalogStatus.error:
                  return ErrorView(
                    message:
                        state.errorMessage ?? 'Не удалось загрузить каталог',
                    onRetry: () =>
                        context.read<CatalogBloc>().add(const CatalogStarted()),
                  );
                case CatalogStatus.data:
                  return _buildContent(context, state);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogState state) {
    final bloc = context.read<CatalogBloc>();
    final email = context.watch<AuthCubit>().state.user?.email ?? '';
    final visibleGames = state.visibleGames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                'В каталоге: ${state.games.length} · '
                'В избранном: ${state.likedCount}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => bloc.add(CatalogSearchChanged(value)),
                decoration: const InputDecoration(
                  hintText: 'Поиск по названию',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => bloc.add(const CatalogFilterToggled()),
                style: OutlinedButton.styleFrom(
                  backgroundColor: state.onlyLiked
                      ? const Color(0xFFFFE3E3)
                      : Colors.transparent,
                ),
                icon: Icon(
                  state.onlyLiked ? Icons.favorite : Icons.favorite_border,
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
              ? EmptyView(text: _emptyText(state))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: visibleGames.length,
                  itemBuilder: (context, index) {
                    final game = visibleGames[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GameCard(
                        game: game,
                        isLiked: state.likedIds.contains(game.id),
                        onLikeTap: () => bloc.add(CatalogLikeToggled(game.id)),
                        onTap: () => _openDetails(context, game.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
