/// Sort options for search results.
enum SortBy { recommended, ratingDesc, priceAsc, priceDesc }

/// Search criteria used across Search, Explore, and Saved screens.
class SearchCriteria {
  final String query;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int? minPriceCents;
  final int? maxPriceCents;
  final Set<String> amenities;
  final double? minRating;
  final SortBy sortBy;
  final String? category;

  const SearchCriteria({
    this.query = '',
    this.checkIn,
    this.checkOut,
    this.guests = 1,
    this.minPriceCents,
    this.maxPriceCents,
    this.amenities = const {},
    this.minRating,
    this.sortBy = SortBy.recommended,
    this.category,
  });

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      checkIn != null ||
      checkOut != null ||
      guests > 1 ||
      minPriceCents != null ||
      maxPriceCents != null ||
      amenities.isNotEmpty ||
      minRating != null ||
      (category != null && category!.isNotEmpty);

  SearchCriteria copyWith({
    String? query,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    int? minPriceCents,
    int? maxPriceCents,
    Set<String>? amenities,
    double? minRating,
    SortBy? sortBy,
    String? category,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
    bool clearCategory = false,
  }) {
    return SearchCriteria(
      query: query ?? this.query,
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      checkOut: clearCheckOut ? null : (checkOut ?? this.checkOut),
      guests: guests ?? this.guests,
      minPriceCents:
          clearMinPrice ? null : (minPriceCents ?? this.minPriceCents),
      maxPriceCents:
          clearMaxPrice ? null : (maxPriceCents ?? this.maxPriceCents),
      amenities: amenities ?? this.amenities,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  static const SearchCriteria empty = SearchCriteria();
}
