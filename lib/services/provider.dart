import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/services/database.dart';
import 'package:funko_vault/services/funko_service.dart';
import 'package:http/http.dart' as http;

class FunkoListNotifier extends StateNotifier<AsyncValue<List<Funko>>> {
  final FunkoService funkoService;
  int offset = 0;

  FunkoListNotifier(this.funkoService) : super(const AsyncValue.loading()) {
    // Initial fetch
    fetchFunkos();
  }

  Future<void> fetchFunkos({bool refresh = false}) async {
    if (refresh) {
      offset = 0; // Reset offset to 0 for refreshing
      state = const AsyncValue.loading();
    } else if (state.value != null) {
      offset = state.value!.length; // Set offset based on the length of the current list
    } else {
      offset = 0; // Initial fetch, start from offset 0
    }

    try {
      final funkos = await funkoService.fetchFunkos(offset);
      if (refresh) {
        state = AsyncValue.data(funkos);
      } else {
        state = AsyncValue.data([...state.value ?? [], ...funkos]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final funkoListProvider = StateNotifierProvider<FunkoListNotifier, AsyncValue<List<Funko>>>((ref) {
  return FunkoListNotifier(FunkoService(http.Client()));
});

class LikedFunkosNotifier extends StateNotifier<List<Funko>> {
  final DatabaseService _dbService;

  LikedFunkosNotifier(this._dbService) : super([]) {
    _loadLikedFunkos();
  }

  Future<void> _loadLikedFunkos() async {
    final funkos = await _dbService.getLikedFunkos();
    state = funkos;
  }

  Future<void> addFunko(Funko funko) async {
    await _dbService.likeFunko(funko);
    state = [...state, funko];
  }

  Future<void> removeFunko(int id) async {
    await _dbService.unlikeFunko(id);
    state = state.where((funko) => funko.id != id).toList();
  }

  Future<bool> isLiked(int id) async {
    return await _dbService.isLiked(Funko(id: id, name: '', series: '', rating: '', scale: '', brand: '', type: '', image: ''));
  }
}

final likedFunkosProvider = StateNotifierProvider<LikedFunkosNotifier, List<Funko>>((ref) {
  final dbService = DatabaseService.instance;
  return LikedFunkosNotifier(dbService);
});

