import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/stay_repository.dart';

enum LoadState { idle, loading, loaded, error }

/// Manages saved-stays (favourites) state across all screens.
class SavedController extends ChangeNotifier {
  final SavedRepository _savedRepo;
  final String _userId;

  SavedController(this._savedRepo, this._userId);

  Set<String> _savedIds = {};
  bool _isLoading = false;
  StreamSubscription<Set<String>>? _sub;

  Set<String> get savedIds => _savedIds;
  bool isSaved(String stayId) => _savedIds.contains(stayId);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await _sub?.cancel();
    _sub = _savedRepo.streamSavedStayIds(_userId).listen(
      (ids) {
        _savedIds = ids;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Optimistic toggle — immediately updates local state then persists.
  Future<void> toggleSaved(String stayId) async {
    final wasAdded = !_savedIds.contains(stayId);
    if (wasAdded) {
      _savedIds = {..._savedIds, stayId};
    } else {
      _savedIds = _savedIds.where((id) => id != stayId).toSet();
    }
    notifyListeners();
    try {
      await _savedRepo.toggleSavedStay(userId: _userId, stayId: stayId);
    } catch (_) {
      // Rollback on failure
      if (wasAdded) {
        _savedIds = _savedIds.where((id) => id != stayId).toSet();
      } else {
        _savedIds = {..._savedIds, stayId};
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
