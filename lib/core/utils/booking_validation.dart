import '../../data/models/booking.dart';

/// Booking validation result.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult.valid()
      : isValid = true,
        error = null;

  const ValidationResult.invalid(this.error) : isValid = false;
}

/// All booking-domain business logic lives here, away from widgets.
abstract class BookingValidation {
  /// Validates check-in and check-out dates.
  static ValidationResult validateBookingDates(
    DateTime? checkIn,
    DateTime? checkOut,
  ) {
    if (checkIn == null) {
      return const ValidationResult.invalid('Please select a check-in date.');
    }
    if (checkOut == null) {
      return const ValidationResult.invalid('Please select a check-out date.');
    }
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final inNorm = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final outNorm = DateTime(checkOut.year, checkOut.month, checkOut.day);

    if (inNorm.isBefore(todayNorm)) {
      return const ValidationResult.invalid('Check-in cannot be in the past.');
    }
    if (!outNorm.isAfter(inNorm)) {
      return const ValidationResult.invalid(
          'Check-out must be after check-in.');
    }
    final nights = outNorm.difference(inNorm).inDays;
    if (nights > 90) {
      return const ValidationResult.invalid(
          'Maximum stay is 90 nights for demo bookings.');
    }
    return const ValidationResult.valid();
  }

  /// Validates the guest count against the stay's capacity.
  static ValidationResult validateGuestCount(int guests, int maxGuests) {
    if (guests < 1) {
      return const ValidationResult.invalid('At least 1 guest is required.');
    }
    if (guests > maxGuests) {
      return ValidationResult.invalid(
          'This stay accommodates a maximum of $maxGuests guests.');
    }
    return const ValidationResult.valid();
  }

  /// Validates and computes a price breakdown.
  static BookingPrice calculateBookingPrice({
    required int nightlyPriceCents,
    required DateTime checkIn,
    required DateTime checkOut,
    int guests = 1,
  }) {
    final nights = checkOut.difference(checkIn).inDays;
    return BookingPrice.calculate(
      nightlyPriceCents: nightlyPriceCents,
      nights: nights,
      guests: guests,
    );
  }
}
