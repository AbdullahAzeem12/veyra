import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/stay.dart';
import '../../data/models/search_criteria.dart';
import '../../data/repositories/stay_repository.dart';
import '../../core/storage/veyra_storage_service.dart';

enum LoadState { idle, loading, loaded, error }

/// Manages the Explore/Home screen state.
class ExploreController extends ChangeNotifier {
  final StayRepository _stayRepo;

  ExploreController(this._stayRepo);

  LoadState _state = LoadState.idle;
  List<Stay> _featured = [];
  List<Stay> _recommended = [];
  String _selectedCategory = 'All';
  String? _errorMessage;
  StreamSubscription<List<Stay>>? _featuredSub;
  StreamSubscription<List<Stay>>? _recommendedSub;

  LoadState get state => _state;
  List<Stay> get featured => _featured;
  List<Stay> get recommended => _recommended;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  static const List<String> defaultCategories = [
    'All',
    'Villa',
    'Château',
    'Island',
    'Overwater',
    'Chalet',
  ];

  List<String> get categories => defaultCategories;

  Future<void> load() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    await _featuredSub?.cancel();
    await _recommendedSub?.cancel();

    _featuredSub = _stayRepo.streamFeaturedStays().listen(
      (stays) {
        _featured = stays;
        if (_recommended.isNotEmpty) {
          _state = LoadState.loaded;
        }
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = e.toString();
        _state = LoadState.error;
        notifyListeners();
      },
    );

    _recommendedSub = _stayRepo.streamRecommendedStays().listen(
      (stays) {
        _recommended = stays;
        _state = LoadState.loaded;
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = e.toString();
        _state = LoadState.error;
        notifyListeners();
      },
    );
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  List<Stay> get filteredRecommended {
    if (_selectedCategory == 'All') return _recommended;
    return _recommended.where((s) => s.category == _selectedCategory).toList();
  }

  Future<void> refresh() async => load();

  @override
  Future<void> dispose() async {
    await _featuredSub?.cancel();
    await _recommendedSub?.cancel();
    super.dispose();
  }
}

/// Manages search-and-filter state.
class StaySearchController extends ChangeNotifier {
  final StayRepository _stayRepo;

  StaySearchController(this._stayRepo) {
    _recentSearches.addAll(VeyraStorageService.getRecentSearches());
  }

  SearchCriteria _criteria = SearchCriteria.empty;
  List<Stay> _results = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;
  final List<String> _recentSearches = [];
  StreamSubscription<List<Stay>>? _sub;
  Timer? _debounce;

  SearchCriteria get criteria => _criteria;
  List<Stay> get results => _results;
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;
  List<String> get recentSearches => _recentSearches;
  bool get hasResults => _results.isNotEmpty;

  void setCriteria(SearchCriteria criteria) {
    _criteria = criteria;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  void updateQuery(String query) {
    setCriteria(_criteria.copyWith(query: query));
  }

  void setCategory(String? category) {
    setCriteria(_criteria.copyWith(category: category));
  }

  void setSortBy(SortBy sort) {
    setCriteria(_criteria.copyWith(sortBy: sort));
  }

  Future<void> load() => _runSearch();

  void clearAll() {
    _criteria = SearchCriteria.empty;
    _runSearch();
  }

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 8) _recentSearches.removeLast();
    VeyraStorageService.addRecentSearch(trimmed);
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    final trimmed = query.trim();
    _recentSearches.remove(trimmed);
    VeyraStorageService.removeRecentSearch(trimmed);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    VeyraStorageService.clearRecentSearches();
    notifyListeners();
  }

  Future<void> _runSearch() async {
    _state = LoadState.loading;
    notifyListeners();
    await _sub?.cancel();
    _sub = _stayRepo.searchStays(_criteria).listen(
      (stays) {
        _results = stays;
        _state = LoadState.loaded;
        if (_criteria.query.isNotEmpty) {
          addRecentSearch(_criteria.query);
        }
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = e.toString();
        _state = LoadState.error;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
