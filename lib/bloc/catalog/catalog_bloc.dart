import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(CatalogLoadInProgress()) {
    on<CatalogLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoadInProgress());
    await emit.forEach<QuerySnapshot<Map<String, dynamic>>>(
      FirebaseFirestore.instance.collection('games').snapshots(),
      onData: (snapshot) => CatalogLoadSuccess(
        snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList(),
      ),
      onError: (error, stackTrace) => CatalogLoadFailure(_describe(error)),
    );
  }

  String _describe(Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Нет доступа к каталогу. Проверьте правила Firestore.';
    }
    return 'Не удалось загрузить каталог';
  }
}
