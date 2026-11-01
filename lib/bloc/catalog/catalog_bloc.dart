// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/catalog_exception.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../domain/entities/game.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required CatalogRepository repository, required String uid})
    : _repository = repository,
      _uid = uid,
      super(const CatalogState()) {
    //события
    on<CatalogStarted>(_onStarted);
    on<CatalogGamesReceived>(_onGamesReceived);
    on<CatalogFavoritesReceived>(_onFavoritesReceived);
    on<CatalogFailed>(_onFailed);
    on<CatalogLikeToggled>(_onLikeToggled);
    on<CatalogFilterToggled>(_onFilterToggled);
    on<CatalogSearchChanged>(_onSearchChanged);
    on<CatalogGameAdded>(_onGameAdded);
    on<CatalogGameUpdated>(_onGameUpdated);
    on<CatalogGameDeleted>(_onGameDeleted);
  }

  final CatalogRepository _repository;
  final String _uid;

  StreamSubscription<List<Game>>? _gamesSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    await _gamesSubscription?.cancel();
    await _favoritesSubscription?.cancel();
    emit(state.copyWith(status: CatalogStatus.loading, query: ''));

    _gamesSubscription = _repository.watchGames().listen(
      (games) => add(CatalogGamesReceived(games)),
      onError: (Object error) => add(CatalogFailed(_describe(error))),
    );
    _favoritesSubscription = _repository
        .watchFavorites(_uid)
        .listen(
          (ids) => add(CatalogFavoritesReceived(ids)),
          onError: (Object error) {},
        );
  }

  void _onGamesReceived(
    CatalogGamesReceived event,
    Emitter<CatalogState> emit,
  ) {
    emit(state.copyWith(status: CatalogStatus.data, games: event.games));
  }

  void _onFavoritesReceived(
    CatalogFavoritesReceived event,
    Emitter<CatalogState> emit,
  ) {
    emit(state.copyWith(likedIds: event.likedIds));
  }

  void _onFailed(CatalogFailed event, Emitter<CatalogState> emit) {
    emit(
      state.copyWith(status: CatalogStatus.error, errorMessage: event.message),
    );
  }

  Future<void> _onLikeToggled(
    CatalogLikeToggled event,
    Emitter<CatalogState> emit,
  ) async {
    final liked = !state.likedIds.contains(event.gameId);
    try {
      await _repository.setFavorite(_uid, event.gameId, liked);
    } catch (e) {
      _notify(emit, _describe(e));
    }
  }

  void _onFilterToggled(
    CatalogFilterToggled event,
    Emitter<CatalogState> emit,
  ) {
    emit(state.copyWith(onlyLiked: !state.onlyLiked));
  }

  void _onSearchChanged(
    CatalogSearchChanged event,
    Emitter<CatalogState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onGameAdded(
    CatalogGameAdded event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.addGame(event.game);
      _notify(emit, 'Игра добавлена');
    } catch (e) {
      _notify(emit, _describe(e));
    }
  }

  Future<void> _onGameUpdated(
    CatalogGameUpdated event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.updateGame(event.game);
      _notify(emit, 'Изменения сохранены');
    } catch (e) {
      _notify(emit, _describe(e));
    }
  }

  Future<void> _onGameDeleted(
    CatalogGameDeleted event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.deleteGame(event.gameId);
      _notify(emit, 'Игра удалена');
    } catch (e) {
      _notify(emit, _describe(e));
    }
  }

  void _notify(Emitter<CatalogState> emit, String text) {
    if (isClosed) return;
    emit(state.copyWith(message: text, messageSeq: state.messageSeq + 1));
  }

  String _describe(Object error) {
    if (error is CatalogException) return error.message;
    return 'Что-то пошло не так. Попробуйте ещё раз.';
  }

  @override
  Future<void> close() async {
    await _gamesSubscription?.cancel();
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
