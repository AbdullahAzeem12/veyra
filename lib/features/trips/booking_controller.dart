import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/booking.dart';
import '../../data/models/stay.dart';
import '../../data/repositories/stay_repository.dart';
import '../../core/utils/booking_validation.dart';

enum BookingStep { input, submitting, confirmed, error }

/// Manages the booking creation flow.
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
  List<Booking> get upcomingBookings =>
      _bookings.where((b) => b.isUpcoming || b.status == BookingStatus.pending).toList();
  List<Booking> get pastBookings =>
      _bookings.where((b) => !b.isUpcoming && b.status != BookingStatus.pending).toList();

  void setCheckIn(DateTime? date) {
    _checkIn = date;
    _checkInError = null;
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

  BookingPrice? computePrice(int nightlyPriceCents) {
    if (_checkIn == null || _checkOut == null) return null;
    if (!_checkOut!.isAfter(_checkIn!)) return null;
    return BookingValidation.calculateBookingPrice(
      nightlyPriceCents: nightlyPriceCents,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      guests: _guests,
    );
  }

  bool validate(int maxGuests) {
    bool ok = true;
    final dateValidation = BookingValidation.validateBookingDates(_checkIn, _checkOut);
    if (!dateValidation.isValid) {
      if (_checkIn == null) {
        _checkInError = dateValidation.error;
      } else {
        _checkOutError = dateValidation.error;
      }
      ok = false;
    }
    final guestValidation = BookingValidation.validateGuestCount(_guests, maxGuests);
    if (!guestValidation.isValid) {
      _guestError = guestValidation.error;
      ok = false;
    }
    notifyListeners();
    return ok;
  }

  Future<void> submitBooking(Stay stay, String userId) async {
    if (!validate(stay.maxGuests)) return;
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
      );
      final bookingId = await _bookingRepo.createBooking(draft);
      _confirmedBooking = _bookings.cast<Booking?>().firstWhere(
            (b) => b?.id == bookingId,
            orElse: () => null,
          );
      // If not yet in stream, build a temporary confirmed booking
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
        bookingReference: 'VYR-DEMO',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _step = BookingStep.confirmed;
    } catch (e) {
      _generalError = e.toString();
      _step = BookingStep.error;
    }
    notifyListeners();
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

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingRepo.cancelBooking(bookingId);
    } catch (e) {
      _generalError = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }
}
