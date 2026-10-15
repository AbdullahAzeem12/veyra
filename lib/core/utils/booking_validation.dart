import '../../data/models/booking.dart';

/// Single-field booking validation result.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult.valid()
      : isValid = true,
        error = null;

  const ValidationResult.invalid(this.error) : isValid = false;
}

/// Structured field-specific date validation result.
class DateValidationResult {
  final bool isValid;
  final String? checkInError;
  final String? checkOutError;
  final String? generalError;

  const DateValidationResult.valid()
      : isValid = true,
        checkInError = null,
        checkOutError = null,
        generalError = null;

  const DateValidationResult.invalid({
    this.checkInError,
    this.checkOutError,
    this.generalError,
  }) : isValid = false;

  String? get firstError => checkInError ?? checkOutError ?? generalError;
}

/// All booking-domain business logic lives here, away from widgets.
abstract class BookingValidation {
  /// Validates check-in and check-out dates with field-specific errors.
  static DateValidationResult validateDates(
    DateTime? checkIn,
    DateTime? checkOut,
  ) {
    if (checkIn == null && checkOut == null) {
      return const DateValidationResult.invalid(
        checkInError: 'Please select a check-in date.',
        checkOutError: 'Please select a check-out date.',
      );
    }
    if (checkIn == null) {
      return const DateValidationResult.invalid(
        checkInError: 'Please select a check-in date.',
      );
    }

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final inNorm = DateTime(checkIn.year, checkIn.month, checkIn.day);

    if (inNorm.isBefore(todayNorm)) {
      return const DateValidationResult.invalid(
        checkInError: 'Check-in cannot be in the past.',
      );
    }

    if (checkOut == null) {
      return const DateValidationResult.invalid(
        checkOutError: 'Please select a check-out date.',
      );
    }

    final outNorm = DateTime(checkOut.year, checkOut.month, checkOut.day);
    if (!outNorm.isAfter(inNorm)) {
      return const DateValidationResult.invalid(
        checkOutError: 'Check-out must be after check-in.',
      );
    }

    final nights = outNorm.difference(inNorm).inDays;
    if (nights > 90) {
      return const DateValidationResult.invalid(
        checkOutError: 'Maximum stay is 90 nights for demo bookings.',
      );
    }

    return const DateValidationResult.valid();
  }

  /// Legacy helper for callers expecting a simple [ValidationResult].
  static ValidationResult validateBookingDates(
    DateTime? checkIn,
    DateTime? checkOut,
  ) {
    final res = validateDates(checkIn, checkOut);
    if (res.isValid) return const ValidationResult.valid();
    return ValidationResult.invalid(res.firstError);
  }

  /// Validates the guest count against the stay's capacity.
  static ValidationResult validateGuestCount(int guests, int maxGuests) {
    if (guests < 1) {
      return const ValidationResult.invalid('At least 1 guest is required.');
    }
    if (guests > maxGuests) {
      return ValidationResult.invalid(
        'This stay accommodates a maximum of $maxGuests guests.',
      );
    }
    return const ValidationResult.valid();
  }

  /// Validates and computes a price breakdown including add-ons.
  static BookingPrice calculateBookingPrice({
    required int nightlyPriceCents,
    required DateTime checkIn,
    required DateTime checkOut,
    int guests = 1,
    int addOnsTotalCents = 0,
    String currency = 'USD',
  }) {
    final nights = checkOut.difference(checkIn).inDays;
    return BookingPrice.calculate(
      nightlyPriceCents: nightlyPriceCents,
      nights: nights,
      guests: guests,
      addOnsTotalCents: addOnsTotalCents,
      currency: currency,
    );
  }
}

