import '../../domain/entities/game.dart';

sealed class CatalogState {}

class CatalogLoadInProgress extends CatalogState {}

class CatalogLoadSuccess extends CatalogState {
  final List<Game> games;

  CatalogLoadSuccess(this.games);
}

class CatalogLoadFailure extends CatalogState {
  final String message;

  CatalogLoadFailure(this.message);
}
