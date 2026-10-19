import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/game.dart';
import '../widgets/game_card.dart';

const baseUrl = 'https://6ad5f6acf71f154ac486408d.mockapi.io';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Game> _games = [];
  bool _isLoading = true;
  String? _error;

  final Set<String> _likedIds = {};
  bool _onlyLiked = false;

  bool _showForm = false;
  bool _isSending = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/games'));
      if (response.statusCode != 200) {
        throw Exception('Статус ${response.statusCode}');
      }
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final games = <Game>[];
      for (final e in list) {
        try {
          games.add(Game.fromJson(e as Map<String, dynamic>));
        } catch (err) {
          throw Exception('Плохой элемент: $e ($err)');
        }
      }
      if (!mounted) return;
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addGame() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Введите название')));
      return;
    }

    setState(() {
      _isSending = true;
    });
    try {
      final newGame = Game(
        id: '',
        title: title,
        subtitle: 'Добавлено вручную',
        genre: GameGenre.other,
        description: '',
        color: '607D8B',
        coverLetter: title.substring(0, 1).toUpperCase(),
      );
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newGame.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Статус ${response.statusCode}');
      }
      final created = Game.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
      if (!mounted) return;
      setState(() {
        _games.insert(0, created);
        _titleController.clear();
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось отправить: $e')));
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
    final visibleGames = _onlyLiked
        ? _games.where((game) => _likedIds.contains(game.id)).toList()
        : _games;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Каталог игр'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_showForm) _buildForm(),
            Expanded(child: _buildContent(visibleGames)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'В каталоге: ${_games.length} · В избранном: ${_likedIds.length}',
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _addGame(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSending ? null : _addGame,
            child: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Game> visibleGames) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Не удалось загрузить каталог:\n$_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadGames,
                child: const Text('Обновить'),
              ),
            ],
          ),
        ),
      );
    }
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
