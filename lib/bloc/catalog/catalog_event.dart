import '../../domain/entities/game.dart';

abstract class CatalogEvent {
  const CatalogEvent();
}

class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

class CatalogLikeToggled extends CatalogEvent {
  final String gameId;

  const CatalogLikeToggled(this.gameId);
}

class CatalogFilterToggled extends CatalogEvent {
  const CatalogFilterToggled();
}

class CatalogSearchChanged extends CatalogEvent {
  final String query;

  const CatalogSearchChanged(this.query);
}

class CatalogGameAdded extends CatalogEvent {
  final Game game;

  const CatalogGameAdded(this.game);
}

class CatalogGameUpdated extends CatalogEvent {
  final Game game;

  const CatalogGameUpdated(this.game);
}

class CatalogGameDeleted extends CatalogEvent {
  final String gameId;

  const CatalogGameDeleted(this.gameId);
}

class CatalogGamesReceived extends CatalogEvent {
  final List<Game> games;

  const CatalogGamesReceived(this.games);
}

class CatalogFavoritesReceived extends CatalogEvent {
  final Set<String> likedIds;

  const CatalogFavoritesReceived(this.likedIds);
}

class CatalogFailed extends CatalogEvent {
  final String message;

  const CatalogFailed(this.message);
}
