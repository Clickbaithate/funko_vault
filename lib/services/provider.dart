import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/services/database.dart';
import 'package:funko_vault/services/funko_service.dart';
import 'package:http/http.dart' as http;

// Notifier for managing the list of funkos
class FunkoListNotifier extends StateNotifier<AsyncValue<List<Funko>>> {

  // FunkoService has the API call function
  // offset is used for pagination
  final FunkoService funkoService;
  int offset = 0;

  // Constructor initializes the state to loading and tries to fetch
  FunkoListNotifier(this.funkoService) : super(const AsyncValue.loading()) {
    fetchFunkos();
  }

  // Method to fetch Funkos, with optional refresh parameter
  // First, set the value of offset and set the state to loading
  // Second, try to fetch 
  Future<void> fetchFunkos({bool refresh = false}) async {

    // If (refresh) then fetch the first 100 funkos only, as if screen was first loaded
    // Else if fetch the next 100 funkos, the API call has a limit of 100 objects
    // Set state to loading
    if (refresh) {
      offset = 0; 
      state = const AsyncValue.loading();
    } else if (state.value != null) {
      offset = state.value!.length; 
    } else {
      offset = 0; 
    }

    // Try to fetch
    try {
      final funkos = await funkoService.fetchFunkos(offset);
      if (refresh) {
        // Replace current state with new funkos if refreshed
        state = AsyncValue.data(funkos);
      } else {
        // Update state with appended funkos
        state = AsyncValue.data([...state.value ?? [], ...funkos]);
      }
    } catch (e, stack) {
      // Set state to error
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for FunkoListNotifier
final funkoListProvider = StateNotifierProvider<FunkoListNotifier, AsyncValue<List<Funko>>>((ref) {
  return FunkoListNotifier(FunkoService(http.Client()));
});

// Notifier for managing liked funko objects
class LikedFunkosNotifier extends StateNotifier<List<Funko>> {

  // DatabaseService has the database methods
  final DatabaseService _dbService;

  // Constructor initializes the state to an empty list and loads liked funkos
  LikedFunkosNotifier(this._dbService) : super([]) {
    _loadLikedFunkos();
  }

  // Calls database method that gets the liked funkos from the database
  Future<void> _loadLikedFunkos() async {
    final funkos = await _dbService.getLikedFunkos();
    state = funkos;
  }

  // Calls database method to add a funko to the liked table
  Future<void> addFunko(Funko funko) async {
    await _dbService.likeFunko(funko);
    state = [...state, funko];
  }

  // Calls database method to remove a funko from the liked table
  Future<void> removeFunko(int id) async {
    await _dbService.unlikeFunko(id);
    state = state.where((funko) => funko.id != id).toList();
  }

  // Calls database method to check if a funko is liked by Id
  Future<bool> isLiked(int id) async {
    return await _dbService.isLiked(Funko(id: id, name: '', series: '', rating: '', scale: '', brand: '', type: '', image: ''));
  }
}

// Provider for LikedFunkosNotifier
final likedFunkosProvider = StateNotifierProvider<LikedFunkosNotifier, List<Funko>>((ref) {
  final dbService = DatabaseService.instance;
  return LikedFunkosNotifier(dbService);
});
