import '../../domain/entities/game.dart';

enum CatalogStatus { loading, data, error }

class CatalogState {
  final CatalogStatus status;
  final List<Game> games;
  final Set<String> likedIds;
  final bool onlyLiked;
  final String query;
  final String? errorMessage;

  final String? message;
  final int messageSeq;

  const CatalogState({
    this.status = CatalogStatus.loading,
    this.games = const [],
    this.likedIds = const {},
    this.onlyLiked = false,
    this.query = '',
    this.errorMessage,
    this.message,
    this.messageSeq = 0,
  });

  int get likedCount => games.where((g) => likedIds.contains(g.id)).length;

  List<Game> get visibleGames {
    final q = query.trim().toLowerCase();
    return games.where((game) {
      if (onlyLiked && !likedIds.contains(game.id)) return false;
      if (q.isNotEmpty && !game.title.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  Game? gameById(String id) {
    for (final game in games) {
      if (game.id == id) return game;
    }
    return null;
  }

  CatalogState copyWith({
    CatalogStatus? status,
    List<Game>? games,
    Set<String>? likedIds,
    bool? onlyLiked,
    String? query,
    String? errorMessage,
    String? message,
    int? messageSeq,
  }) {
    return CatalogState(
      status: status ?? this.status,
      games: games ?? this.games,
      likedIds: likedIds ?? this.likedIds,
      onlyLiked: onlyLiked ?? this.onlyLiked,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      messageSeq: messageSeq ?? this.messageSeq,
    );
  }
}
