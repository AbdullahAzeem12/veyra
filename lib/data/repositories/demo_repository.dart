import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stay.dart';
import '../models/search_criteria.dart';
import '../models/booking.dart';
import '../demo/demo_data.dart';
import 'stay_repository.dart';

/// In-memory demo implementation of all repositories.
/// No network required — operates from seeded [DemoData].

class DemoStayRepository implements StayRepository {
  final List<Stay> _all = DemoData.allStays;

  @override
  Stream<List<Stay>> streamFeaturedStays() =>
      Stream.value(_all.where((s) => s.isFeatured && s.isActive).toList());

  @override
  Stream<List<Stay>> streamRecommendedStays() =>
      Stream.value(sortSearchResults(
        _all.where((s) => s.isActive).toList(),
        SortBy.ratingDesc,
      ));

  @override
  Stream<List<Stay>> searchStays(SearchCriteria criteria) =>
      Stream.value(applySearchFilters(_all, criteria));

  @override
  Stream<Stay?> streamStayById(String stayId) {
    try {
      return Stream.value(_all.firstWhere((s) => s.id == stayId));
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  Stream<List<Stay>> streamDestinationStays(String destinationId) =>
      Stream.value(
        _all.where((s) => s.destinationId == destinationId && s.isActive).toList(),
      );

  @override
  Future<void> dispose() async {}

  /// Shared filtering logic — also used by StaySearchController for local filtering.
  static List<Stay> applySearchFilters(List<Stay> stays, SearchCriteria c) {
    var results = stays.where((s) => s.isActive).toList();

    if (c.query.isNotEmpty) {
      final q = c.query.toLowerCase();
      results = results
          .where(
            (s) =>
                s.title.toLowerCase().contains(q) ||
                s.destination.toLowerCase().contains(q) ||
                s.country.toLowerCase().contains(q) ||
                s.description.toLowerCase().contains(q),
          )
          .toList();
    }

    if (c.category != null && c.category!.isNotEmpty && c.category != 'All') {
      results = results.where((s) => s.category == c.category).toList();
    }

    if (c.minPriceCents != null) {
      results = results
          .where((s) => s.nightlyPriceCents >= c.minPriceCents!)
          .toList();
    }
    if (c.maxPriceCents != null) {
      results = results
          .where((s) => s.nightlyPriceCents <= c.maxPriceCents!)
          .toList();
    }
    if (c.minRating != null) {
      results = results.where((s) => s.rating >= c.minRating!).toList();
    }
    if (c.amenities.isNotEmpty) {
      results = results
          .where((s) => c.amenities.every(s.amenities.contains))
          .toList();
    }
    if (c.guests > 1) {
      results = results.where((s) => s.maxGuests >= c.guests).toList();
    }

    return sortSearchResults(results, c.sortBy);
  }

  static List<Stay> sortSearchResults(List<Stay> stays, SortBy sort) {
    final sorted = List<Stay>.from(stays);
    switch (sort) {
      case SortBy.recommended:
        sorted.sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
      case SortBy.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.priceAsc:
        sorted.sort(
            (a, b) => a.nightlyPriceCents.compareTo(b.nightlyPriceCents));
      case SortBy.priceDesc:
        sorted.sort(
            (a, b) => b.nightlyPriceCents.compareTo(a.nightlyPriceCents));
    }
    return sorted;
  }
}

/// In-memory saved-stays with SharedPreferences persistence and proper per-user isolation.
class DemoSavedRepository implements SavedRepository {
  final _controllers = <String, StreamController<Set<String>>>{};
  final _savedMap = <String, Set<String>>{};
  final Set<String> _loadedUsers = {};

  Future<void> _ensureLoaded(String userId) async {
    if (_loadedUsers.contains(userId)) return;
    _loadedUsers.add(userId);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_$userId') ?? [];
    _savedMap[userId] = Set<String>.from(saved);
  }

  @override
  Stream<Set<String>> streamSavedStayIds(String userId) {
    _ensureLoaded(userId).then((_) {
      _controllers[userId]?.add(_savedMap[userId] ?? {});
    });
    _controllers[userId] ??= StreamController<Set<String>>.broadcast();
    return _controllers[userId]!.stream;
  }

  @override
  Future<void> toggleSavedStay({
    required String userId,
    required String stayId,
  }) async {
    await _ensureLoaded(userId);
    _savedMap[userId] ??= {};
    final set = _savedMap[userId]!;
    if (set.contains(stayId)) {
      set.remove(stayId);
    } else {
      set.add(stayId);
    }
    _controllers[userId]?.add(Set<String>.from(set));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_$userId', set.toList());
  }

  @override
  Future<void> dispose() async {
    for (final c in _controllers.values) {
      await c.close();
    }
    _controllers.clear();
  }
}

/// In-memory booking repository with full add-on and cancellation lifecycle tracking.
class DemoBookingRepository implements BookingRepository {
  final _bookings = <String, Booking>{};
  final StreamController<List<Booking>> _controller =
      StreamController<List<Booking>>.broadcast();

  List<Booking> _bookingsForUser(String userId) {
    _seedBookingsIfEmpty(userId);
    return _bookings.values.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _seedBookingsIfEmpty(String userId) {
    if (_bookings.values.any((b) => b.userId == userId)) return;
    final now = DateTime.now();

    // 1. Upcoming Luxury Stay: Bora Bora Overwater Bungalow with Helicopter & Champagne
    final b1 = Booking(
      id: 'BK_SEED_1',
      userId: userId,
      stayId: 's001',
      stayTitle: 'Pearl Overwater Bungalow',
      stayImageUrl:
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1200',
      destination: 'Bora Bora, French Polynesia',
      checkIn: now.add(const Duration(days: 14)),
      checkOut: now.add(const Duration(days: 19)),
      guestCount: 2,
      price: BookingPrice.calculate(
        nightlyPriceCents: 58000,
        nights: 5,
        guests: 2,
        addOnsTotalCents: 170000,
      ),
      status: BookingStatus.confirmed,
      bookingReference: 'VYR-884920',
      addOns: const [
        BookingAddOn(
          id: 'helicopter',
          title: 'Airport Helicopter Transfer',
          subtitle: 'Executive twin-engine scenic lagoon transfer',
          priceCents: 125000,
        ),
        BookingAddOn(
          id: 'champagne',
          title: 'Dom Pérignon Vintage 2013',
          subtitle: 'Chilled bottle with crystal flutes upon arrival',
          priceCents: 45000,
        ),
      ],
      specialRequests:
          'Lagoon-facing overwater suite requested. Late anniversary arrival.',
      cancellationPolicy: const CancellationPolicy(),
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );

    // 2. Upcoming Luxury Stay: The Chedi Alpine Chalet in Zermatt & Alps
    final b2 = Booking(
      id: 'BK_SEED_2',
      userId: userId,
      stayId: 's016',
      stayTitle: 'The Chedi Alpine Chalet',
      stayImageUrl:
          'https://images.unsplash.com/photo-1502784444187-359ac186c5bb?w=1200',
      destination: 'Zermatt & Alps, Switzerland',
      checkIn: now.add(const Duration(days: 45)),
      checkOut: now.add(const Duration(days: 49)),
      guestCount: 2,
      price: BookingPrice.calculate(
        nightlyPriceCents: 98000,
        nights: 4,
        guests: 2,
        addOnsTotalCents: 60000,
      ),
      status: BookingStatus.confirmed,
      bookingReference: 'VYR-771924',
      addOns: const [
        BookingAddOn(
          id: 'butler',
          title: 'Private Ski Concierge & Butler',
          subtitle: 'Daily equipment fitting and heated boot preparation',
          priceCents: 60000,
        ),
      ],
      specialRequests: 'Wood-burning fireplace pre-lit before arrival.',
      cancellationPolicy: const CancellationPolicy(),
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 12)),
    );

    // 3. Completed Past Stay: The Ritz-Carlton Kyoto
    final b3 = Booking(
      id: 'BK_SEED_3',
      userId: userId,
      stayId: 's003',
      stayTitle: 'The Ritz-Carlton Kyoto',
      stayImageUrl:
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200',
      destination: 'Kyoto, Japan',
      checkIn: now.subtract(const Duration(days: 60)),
      checkOut: now.subtract(const Duration(days: 56)),
      guestCount: 2,
      price: BookingPrice.calculate(
        nightlyPriceCents: 82000,
        nights: 4,
        guests: 2,
      ),
      status: BookingStatus.completed,
      bookingReference: 'VYR-491022',
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now.subtract(const Duration(days: 56)),
    );

    // 4. Completed Past Stay: Caldera Cliff Suite in Santorini
    final b4 = Booking(
      id: 'BK_SEED_4',
      userId: userId,
      stayId: 's005',
      stayTitle: 'Caldera Cliff Suite',
      stayImageUrl:
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=1200',
      destination: 'Santorini, Greece',
      checkIn: now.subtract(const Duration(days: 120)),
      checkOut: now.subtract(const Duration(days: 117)),
      guestCount: 2,
      price: BookingPrice.calculate(
        nightlyPriceCents: 67000,
        nights: 3,
        guests: 2,
      ),
      status: BookingStatus.completed,
      bookingReference: 'VYR-312984',
      createdAt: now.subtract(const Duration(days: 150)),
      updatedAt: now.subtract(const Duration(days: 117)),
    );

    // 5. Cancelled Stay (Full Refund Processed): Burj View Sky Suite
    final priceDubai = BookingPrice.calculate(
      nightlyPriceCents: 95000,
      nights: 3,
      guests: 2,
    );
    final b5 = Booking(
      id: 'BK_SEED_5',
      userId: userId,
      stayId: 's009',
      stayTitle: 'Burj View Sky Suite',
      stayImageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200',
      destination: 'Dubai, UAE',
      checkIn: now.add(const Duration(days: 8)),
      checkOut: now.add(const Duration(days: 11)),
      guestCount: 2,
      price: priceDubai,
      status: BookingStatus.cancelled,
      bookingReference: 'VYR-109283',
      refundStatus: RefundStatus.refunded,
      refundAmountCents: priceDubai.totalCents,
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now.subtract(const Duration(days: 3)),
    );

    // 6. Cancelled Stay (Refund Pending Reconciliation): Château de Chambord Royal Estate
    final priceFrance = BookingPrice.calculate(
      nightlyPriceCents: 89000,
      nights: 2,
      guests: 2,
    );
    final b6 = Booking(
      id: 'BK_SEED_6',
      userId: userId,
      stayId: 's012',
      stayTitle: 'Château de Chambord Royal Estate',
      stayImageUrl:
          'https://images.unsplash.com/photo-1585543805890-6051f7829f98?w=1200',
      destination: 'Loire & Riviera, France',
      checkIn: now.add(const Duration(days: 25)),
      checkOut: now.add(const Duration(days: 27)),
      guestCount: 2,
      price: priceFrance,
      status: BookingStatus.cancelled,
      bookingReference: 'VYR-554120',
      refundStatus: RefundStatus.pending,
      refundAmountCents: priceFrance.totalCents,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _bookings[b1.id] = b1;
    _bookings[b2.id] = b2;
    _bookings[b3.id] = b3;
    _bookings[b4.id] = b4;
    _bookings[b5.id] = b5;
    _bookings[b6.id] = b6;
  }

  @override
  Stream<List<Booking>> streamBookings(String userId) {
    // Emit current state immediately then updates
    Future.microtask(() => _controller.add(_bookingsForUser(userId)));
    return _controller.stream.map((_) => _bookingsForUser(userId));
  }

  @override
  Future<String> createBooking(BookingDraft draft) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final id = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final ref = 'VYR-${Random().nextInt(900000) + 100000}';
    final now = DateTime.now();
    final booking = Booking(
      id: id,
      userId: draft.userId,
      stayId: draft.stayId,
      stayTitle: draft.stayTitle,
      stayImageUrl: draft.stayImageUrl,
      destination: draft.destination,
      checkIn: draft.checkIn,
      checkOut: draft.checkOut,
      guestCount: draft.guestCount,
      price: draft.price,
      status: BookingStatus.confirmed,
      bookingReference: ref,
      addOns: draft.addOns,
      specialRequests: draft.specialRequests,
      paymentMethodId: draft.paymentMethodId,
      cancellationPolicy: draft.cancellationPolicy,
      createdAt: now,
      updatedAt: now,
    );
    _bookings[id] = booking;
    _controller.add(_bookings.values.toList());
    return id;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final booking = _bookings[bookingId];
    if (booking == null) return;
    if (!booking.isCancellable) {
      throw Exception('This booking cannot be cancelled.');
    }
    final refundAmount = (booking.price.totalCents *
            (booking.cancellationPolicy.refundPercentage / 100))
        .round();
    _bookings[bookingId] = booking.copyWith(
      status: BookingStatus.cancelled,
      refundStatus: RefundStatus.pending,
      refundAmountCents: refundAmount,
      updatedAt: DateTime.now(),
    );
    _controller.add(_bookings.values.toList());
  }

  /// Reconcile refund state (e.g. from payment webhook or backend response)
  void reconcileRefund(String bookingId) {
    final booking = _bookings[bookingId];
    if (booking != null && booking.status == BookingStatus.cancelled) {
      _bookings[bookingId] = booking.copyWith(
        refundStatus: RefundStatus.refunded,
        updatedAt: DateTime.now(),
      );
      _controller.add(_bookings.values.toList());
    }
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
