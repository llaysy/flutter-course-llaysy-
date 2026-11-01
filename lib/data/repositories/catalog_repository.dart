import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/game.dart';
import 'catalog_exception.dart';

class CatalogRepository {
  CatalogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _games =>
      _db.collection('games');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<List<Game>> watchGames() {
    return _games
        .snapshots() //дает поток
        .map<List<Game>>((snapshot) {
          if (snapshot.metadata.isFromCache && snapshot.docs.isEmpty) {
            throw const CatalogException(
              'Нет соединения с сервером. Проверьте интернет '
              'и нажмите «Обновить».',
            );
          }
          final games = snapshot.docs
              .map((doc) => Game.fromFirestore(doc))
              .toList();
          games.sort(_newestFirst);
          return games;
        })
        .transform(
          StreamTransformer<List<Game>, List<Game>>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              sink.addError(_toException(error), stackTrace);
            },
          ),
        );
  }

  Stream<Set<String>> watchFavorites(String uid) {
    return _userDoc(uid).snapshots().map<Set<String>>((doc) {
      final list = doc.data()?['favorites'];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return <String>{};
    });
  }

  Future<void> setFavorite(String uid, String gameId, bool liked) {
    return _guard(() async {
      await _userDoc(uid).set({
        'favorites': liked
            ? FieldValue.arrayUnion([gameId])
            : FieldValue.arrayRemove([gameId]),
      }, SetOptions(merge: true));
    });
  }

  Future<void> addGame(Game game) {
    return _guard(() async {
      await _games.add({...game.toJson(), 'createdAt': Timestamp.now()});
    });
  }

  Future<void> updateGame(Game game) {
    return _guard(() async {
      await _games.doc(game.id).update(game.toJson());
    });
  }

  Future<void> deleteGame(String id) {
    return _guard(() async {
      await _games.doc(id).delete();
    });
  }

  static int _newestFirst(Game a, Game b) {
    final ad = a.createdAt;
    final bd = b.createdAt;
    if (ad == null && bd == null) return a.title.compareTo(b.title);
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw _toException(e);
    }
  }

  CatalogException _toException(Object error) {
    if (error is CatalogException) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const CatalogException(
            'Нет доступа к данным. Проверьте вход и правила Firestore.',
          );
        case 'unavailable':
          return const CatalogException(
            'Нет соединения с сервером. Проверьте интернет.',
          );
        default:
          return CatalogException('Ошибка Firestore: ${error.code}');
      }
    }
    return const CatalogException(
      'Не удалось выполнить операцию. Попробуйте ещё раз.',
    );
  }
}
