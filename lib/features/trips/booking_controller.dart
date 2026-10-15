import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/booking.dart';
import '../../data/models/stay.dart';
import '../../data/repositories/stay_repository.dart';
import '../../core/utils/booking_validation.dart';

enum BookingStep { input, submitting, confirmed, error }

/// Manages the booking creation flow and trip itineraries.
class BookingController extends ChangeNotifier {
  final BookingRepository _bookingRepo;

  BookingController(this._bookingRepo);

  // ── Booking state ─────────────────────────────────────────────────────────
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  BookingStep _step = BookingStep.input;
  String? _checkInError;
  String? _checkOutError;
  String? _guestError;
  String? _generalError;
  Booking? _confirmedBooking;

  // ── Trips state ───────────────────────────────────────────────────────────
  List<Booking> _bookings = [];
  StreamSubscription<List<Booking>>? _bookingSub;

  DateTime? get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  int get guests => _guests;
  BookingStep get step => _step;
  String? get checkInError => _checkInError;
  String? get checkOutError => _checkOutError;
  String? get guestError => _guestError;
  String? get generalError => _generalError;
  Booking? get confirmedBooking => _confirmedBooking;
  List<Booking> get bookings => _bookings;

  /// Upcoming active reservations: confirmed in future or pending.
  List<Booking> get upcomingBookings => _bookings
      .where((b) =>
          (b.status == BookingStatus.confirmed &&
              b.checkIn.isAfter(DateTime.now())) ||
          b.status == BookingStatus.pending)
      .toList();

  /// Completed past trips (only completed or past confirmed stays; excludes cancelled).
  List<Booking> get pastBookings => _bookings
      .where((b) =>
          b.status == BookingStatus.completed ||
          (b.status == BookingStatus.confirmed &&
              !b.checkIn.isAfter(DateTime.now())))
      .toList();

  /// Dedicated list of cancelled reservations with transparent refund status.
  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  void setCheckIn(DateTime? date) {
    _checkIn = date;
    _checkInError = null;
    // Reset checkout if check-in is set after or equal to current checkout
    if (date != null && _checkOut != null && !_checkOut!.isAfter(date)) {
      _checkOut = null;
      _checkOutError = null;
    }
    notifyListeners();
  }

  void setCheckOut(DateTime? date) {
    _checkOut = date;
    _checkOutError = null;
    notifyListeners();
  }

  void setGuests(int count) {
    _guests = count;
    _guestError = null;
    notifyListeners();
  }

  BookingPrice? computePrice(int nightlyPriceCents, {int addOnsTotalCents = 0}) {
    if (_checkIn == null || _checkOut == null) return null;
    if (!_checkOut!.isAfter(_checkIn!)) return null;
    return BookingValidation.calculateBookingPrice(
      nightlyPriceCents: nightlyPriceCents,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      guests: _guests,
      addOnsTotalCents: addOnsTotalCents,
    );
  }

  bool validate(int maxGuests) {
    bool ok = true;
    final dateValidation = BookingValidation.validateDates(_checkIn, _checkOut);
    if (!dateValidation.isValid) {
      _checkInError = dateValidation.checkInError;
      _checkOutError = dateValidation.checkOutError;
      _generalError = dateValidation.generalError;
      ok = false;
    } else {
      _checkInError = null;
      _checkOutError = null;
    }

    final guestValidation =
        BookingValidation.validateGuestCount(_guests, maxGuests);
    if (!guestValidation.isValid) {
      _guestError = guestValidation.error;
      ok = false;
    } else {
      _guestError = null;
    }

    notifyListeners();
    return ok;
  }

  /// Submits the booking with full structured add-ons and payment details.
  /// Returns `true` only if authoritative booking creation succeeded.
  Future<bool> submitBooking(
    Stay stay,
    String userId, {
    List<BookingAddOn> addOns = const [],
    String? specialRequests,
    String? paymentMethodId,
  }) async {
    if (!validate(stay.maxGuests)) return false;

    _step = BookingStep.submitting;
    _generalError = null;
    notifyListeners();

    try {
      final draft = BookingDraft(
        userId: userId,
        stayId: stay.id,
        stayTitle: stay.title,
        stayImageUrl: stay.primaryImageUrl,
        destination: stay.destination,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guestCount: _guests,
        nightlyPriceCents: stay.nightlyPriceCents,
        addOns: addOns,
        specialRequests: specialRequests,
        paymentMethodId: paymentMethodId,
      );

      final bookingId = await _bookingRepo.createBooking(draft);

      _confirmedBooking = _bookings.cast<Booking?>().firstWhere(
            (b) => b?.id == bookingId,
            orElse: () => null,
          );

      // If stream has not yet emitted, construct exact snapshot from validated draft
      _confirmedBooking ??= Booking(
        id: bookingId,
        userId: userId,
        stayId: stay.id,
        stayTitle: stay.title,
        stayImageUrl: stay.primaryImageUrl,
        destination: stay.destination,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guestCount: _guests,
        price: draft.price,
        status: BookingStatus.confirmed,
        bookingReference: 'VYR-${bookingId.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)}',
        addOns: addOns,
        specialRequests: specialRequests,
        paymentMethodId: paymentMethodId,
        cancellationPolicy: draft.cancellationPolicy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _step = BookingStep.confirmed;
      notifyListeners();
      return true;
    } catch (e) {
      _generalError = e.toString();
      _step = BookingStep.error;
      notifyListeners();
      return false;
    }
  }

  void resetBookingForm() {
    _checkIn = null;
    _checkOut = null;
    _guests = 1;
    _step = BookingStep.input;
    _checkInError = null;
    _checkOutError = null;
    _guestError = null;
    _generalError = null;
    _confirmedBooking = null;
    notifyListeners();
  }

  Future<void> loadBookings(String userId) async {
    await _bookingSub?.cancel();
    _bookingSub = _bookingRepo.streamBookings(userId).listen(
      (bookings) {
        _bookings = bookings;
        notifyListeners();
      },
    );
  }

  /// Cancels booking asynchronously and returns boolean outcome.
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingRepo.cancelBooking(bookingId);
      return true;
    } catch (e) {
      _generalError = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }
}
