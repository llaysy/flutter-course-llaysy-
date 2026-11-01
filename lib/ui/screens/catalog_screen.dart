import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';
import '../widgets/game_card.dart';

const _collectionName = 'games';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _gamesStream = FirebaseFirestore.instance
      .collection(_collectionName)
      .snapshots();

  final Set<String> _likedIds = {};
  bool _onlyLiked = false;

  bool _showForm = false;
  bool _isSending = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _addGame() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Введите название')));
      return;
    }
    final subtitle = _subtitleController.text.trim();

    setState(() {
      _isSending = true;
    });
    try {
      final newGame = Game(
        id: '',
        title: title,
        subtitle: subtitle.isEmpty ? 'Добавлено вручную' : subtitle,
        genre: GameGenre.other,
        description: '',
        color: '607D8B',
        coverLetter: title.substring(0, 1).toUpperCase(),
      );
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .add(newGame.toJson());
      _titleController.clear();
      _subtitleController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось сохранить: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _toggleLike(String id) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Каталог игр'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            tooltip: 'Добавить',
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _gamesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Ошибка: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final games = snapshot.data!.docs
                .map((doc) => Game.fromFirestore(doc))
                .toList();
            final visibleGames = _onlyLiked
                ? games.where((g) => _likedIds.contains(g.id)).toList()
                : games;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(games.length),
                if (_showForm) _buildForm(),
                Expanded(child: _buildList(visibleGames)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            'В каталоге: $total · В избранном: ${_likedIds.length}',
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
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Название',
              border: OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: 'Подпись (необязательно)',
              border: OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _addGame(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isSending ? null : _addGame,
              child: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Отправить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Game> visibleGames) {
    if (visibleGames.isEmpty) {
      return const Center(child: Text('Ничего не нашлось'));
    }
    return ListView.builder(
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
    );
  }
}
