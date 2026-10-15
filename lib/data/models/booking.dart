/// Booking status enum — defines valid lifecycle transitions.
enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  String get displayLabel {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

/// Immutable breakdown of a booking's cost (in cents).
class BookingPrice {
  final int nights;
  final int nightlyPriceCents;
  final int nightlySubtotalCents;
  final int cleaningFeeCents;
  final int serviceFeeCents;
  final int discountCents;
  final int taxesCents;
  final int totalCents;
  final String currency;

  const BookingPrice({
    required this.nights,
    required this.nightlyPriceCents,
    required this.nightlySubtotalCents,
    required this.cleaningFeeCents,
    required this.serviceFeeCents,
    this.discountCents = 0,
    this.taxesCents = 0,
    required this.totalCents,
    this.currency = 'USD',
  });

  String _fmt(int cents) => '\$${(cents / 100).toStringAsFixed(0)}';

  String get nightlyPriceDisplay => _fmt(nightlyPriceCents);
  String get nightlySubtotalDisplay => _fmt(nightlySubtotalCents);
  String get cleaningFeeDisplay => _fmt(cleaningFeeCents);
  String get serviceFeeDisplay => _fmt(serviceFeeCents);
  String get discountDisplay => '-\$${(discountCents / 100).toStringAsFixed(0)}';
  String get taxesDisplay => _fmt(taxesCents);
  String get totalDisplay => _fmt(totalCents);

  /// Compute a price breakdown from nightly rate, nights, guest count, and fee policy.
  factory BookingPrice.calculate({
    required int nightlyPriceCents,
    required int nights,
    int guests = 1,
    String currency = 'USD',
  }) {
    final nightlySubtotal = nightlyPriceCents * nights;
    // Demo fee policy: 10% cleaning, 12% service
    final cleaningFee = (nightlySubtotal * 0.10).round();
    final serviceFee = (nightlySubtotal * 0.12).round();
    // Seasonal discount: 15% discount if 3+ nights
    final discount = nights >= 3 ? (nightlySubtotal * 0.15).round() : 0;
    // Taxes: 8% on net stay + fees
    final taxableAmount = (nightlySubtotal - discount) + cleaningFee + serviceFee;
    final taxes = (taxableAmount * 0.08).round();
    final total = nightlySubtotal + cleaningFee + serviceFee - discount + taxes;
    return BookingPrice(
      nights: nights,
      nightlyPriceCents: nightlyPriceCents,
      nightlySubtotalCents: nightlySubtotal,
      cleaningFeeCents: cleaningFee,
      serviceFeeCents: serviceFee,
      discountCents: discount,
      taxesCents: taxes,
      totalCents: total,
      currency: currency,
    );
  }
}

/// A completed booking record.
class Booking {
  final String id;
  final String userId;
  final String stayId;
  final String stayTitle;
  final String stayImageUrl;
  final String destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final BookingPrice price;
  final BookingStatus status;
  final String bookingReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.stayId,
    required this.stayTitle,
    required this.stayImageUrl,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.price,
    required this.status,
    required this.bookingReference,
    required this.createdAt,
    required this.updatedAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  bool get isUpcoming =>
      status == BookingStatus.confirmed &&
      checkIn.isAfter(DateTime.now());

  bool get isCancellable =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  Booking copyWith({BookingStatus? status, DateTime? updatedAt}) {
    return Booking(
      id: id,
      userId: userId,
      stayId: stayId,
      stayTitle: stayTitle,
      stayImageUrl: stayImageUrl,
      destination: destination,
      checkIn: checkIn,
      checkOut: checkOut,
      guestCount: guestCount,
      price: price,
      status: status ?? this.status,
      bookingReference: bookingReference,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'stayId': stayId,
        'stayTitle': stayTitle,
        'stayImageUrl': stayImageUrl,
        'destination': destination,
        'checkIn': checkIn.millisecondsSinceEpoch,
        'checkOut': checkOut.millisecondsSinceEpoch,
        'guestCount': guestCount,
        'nightlyPriceCents': price.nightlyPriceCents,
        'totalCents': price.totalCents,
        'cleaningFeeCents': price.cleaningFeeCents,
        'serviceFeeCents': price.serviceFeeCents,
        'nights': price.nights,
        'status': status.name,
        'bookingReference': bookingReference,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    final nights = (map['nights'] as num?)?.toInt() ?? 1;
    final nightlyPriceCents = (map['nightlyPriceCents'] as num?)?.toInt() ?? 0;
    return Booking(
      id: docId,
      userId: map['userId'] as String? ?? '',
      stayId: map['stayId'] as String? ?? '',
      stayTitle: map['stayTitle'] as String? ?? '',
      stayImageUrl: map['stayImageUrl'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      checkIn: DateTime.fromMillisecondsSinceEpoch(
          (map['checkIn'] as num?)?.toInt() ?? 0),
      checkOut: DateTime.fromMillisecondsSinceEpoch(
          (map['checkOut'] as num?)?.toInt() ?? 0),
      guestCount: (map['guestCount'] as num?)?.toInt() ?? 1,
      price: BookingPrice.calculate(
        nightlyPriceCents: nightlyPriceCents,
        nights: nights,
      ),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      bookingReference: map['bookingReference'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as num?)?.toInt() ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (map['updatedAt'] as num?)?.toInt() ?? 0),
    );
  }
}

/// Draft used to create a new booking.
class BookingDraft {
  final String userId;
  final String stayId;
  final String stayTitle;
  final String stayImageUrl;
  final String destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final int nightlyPriceCents;

  const BookingDraft({
    required this.userId,
    required this.stayId,
    required this.stayTitle,
    required this.stayImageUrl,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.nightlyPriceCents,
  });

  int get nights => checkOut.difference(checkIn).inDays;
  BookingPrice get price =>
      BookingPrice.calculate(nightlyPriceCents: nightlyPriceCents, nights: nights);
}
