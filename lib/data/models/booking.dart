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

/// Explicit refund processing status.
enum RefundStatus {
  none,
  requested,
  pending,
  refunded,
  partiallyRefunded,
  notEligible;

  String get displayLabel {
    switch (this) {
      case RefundStatus.none:
        return 'None';
      case RefundStatus.requested:
        return 'Refund Requested';
      case RefundStatus.pending:
        return 'Refund Processing';
      case RefundStatus.refunded:
        return 'Refund Issued';
      case RefundStatus.partiallyRefunded:
        return 'Partially Refunded';
      case RefundStatus.notEligible:
        return 'Not Eligible for Refund';
    }
  }
}

/// Curated luxury add-on service.
class BookingAddOn {
  final String id;
  final String title;
  final String subtitle;
  final int priceCents;
  final bool isPerNight;

  const BookingAddOn({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceCents,
    this.isPerNight = false,
  });

  int calculateTotalCents(int nights) =>
      isPerNight ? priceCents * (nights > 0 ? nights : 1) : priceCents;

  String formattedPrice(int nights) {
    final total = calculateTotalCents(nights);
    return '\$${(total / 100).toStringAsFixed(0)}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'priceCents': priceCents,
        'isPerNight': isPerNight,
      };

  factory BookingAddOn.fromMap(Map<String, dynamic> map) => BookingAddOn(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        subtitle: map['subtitle'] as String? ?? '',
        priceCents: (map['priceCents'] as num?)?.toInt() ?? 0,
        isPerNight: map['isPerNight'] as bool? ?? false,
      );

  // Standard luxury offerings
  static const helicopter = BookingAddOn(
    id: 'helicopter',
    title: 'Twin-Engine Helicopter Transfer',
    subtitle: 'Runway-to-helipad direct transfer (+\$450)',
    priceCents: 45000,
  );

  static const champagne = BookingAddOn(
    id: 'champagne',
    title: 'Chilled Dom Pérignon on Arrival',
    subtitle: 'Placed in master suite with artisan truffles (+\$280)',
    priceCents: 28000,
  );

  static const butler = BookingAddOn(
    id: 'butler',
    title: '24/7 Dedicated Private Butler',
    subtitle: 'Personal concierge & packing service (+\$350/night)',
    priceCents: 35000,
    isPerNight: true,
  );

  static const yacht = BookingAddOn(
    id: 'yacht',
    title: 'Sunset Riva Yacht Charter',
    subtitle: '4-hour private cruise with sommelier (+\$850)',
    priceCents: 85000,
  );
}

/// Server-returned or contract cancellation policy.
class CancellationPolicy {
  final String policyType;
  final int refundPercentage;
  final String description;

  const CancellationPolicy({
    this.policyType = 'VIP Concierge Guarantee',
    this.refundPercentage = 100,
    this.description =
        'Full refund up to 48 hours prior to check-in. Refund processed through authoritative payment provider.',
  });

  Map<String, dynamic> toMap() => {
        'policyType': policyType,
        'refundPercentage': refundPercentage,
        'description': description,
      };

  factory CancellationPolicy.fromMap(Map<String, dynamic> map) =>
      CancellationPolicy(
        policyType: map['policyType'] as String? ?? 'VIP Concierge Guarantee',
        refundPercentage: (map['refundPercentage'] as num?)?.toInt() ?? 100,
        description: map['description'] as String? ??
            'Full refund up to 48 hours prior to check-in.',
      );
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
  final int addOnsTotalCents;
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
    this.addOnsTotalCents = 0,
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
  String get addOnsDisplay => _fmt(addOnsTotalCents);
  String get totalDisplay => _fmt(totalCents);

  /// Compute a price breakdown from nightly rate, nights, guest count, add-ons, and fee policy.
  factory BookingPrice.calculate({
    required int nightlyPriceCents,
    required int nights,
    int guests = 1,
    int addOnsTotalCents = 0,
    String currency = 'USD',
  }) {
    final validNights = nights > 0 ? nights : 1;
    final nightlySubtotal = nightlyPriceCents * validNights;
    // Fee policy: 10% cleaning, 12% service
    final cleaningFee = (nightlySubtotal * 0.10).round();
    final serviceFee = (nightlySubtotal * 0.12).round();
    // Seasonal discount: 15% discount if 3+ nights
    final discount = validNights >= 3 ? (nightlySubtotal * 0.15).round() : 0;
    // Taxes: 8% on net stay + fees + add-ons
    final taxableAmount =
        (nightlySubtotal - discount) + cleaningFee + serviceFee + addOnsTotalCents;
    final taxes = (taxableAmount * 0.08).round();
    final total = nightlySubtotal +
        cleaningFee +
        serviceFee -
        discount +
        taxes +
        addOnsTotalCents;

    return BookingPrice(
      nights: validNights,
      nightlyPriceCents: nightlyPriceCents,
      nightlySubtotalCents: nightlySubtotal,
      cleaningFeeCents: cleaningFee,
      serviceFeeCents: serviceFee,
      discountCents: discount,
      taxesCents: taxes,
      addOnsTotalCents: addOnsTotalCents,
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
  final List<BookingAddOn> addOns;
  final String? specialRequests;
  final String? paymentMethodId;
  final RefundStatus refundStatus;
  final int refundAmountCents;
  final CancellationPolicy cancellationPolicy;
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
    this.addOns = const [],
    this.specialRequests,
    this.paymentMethodId,
    this.refundStatus = RefundStatus.none,
    this.refundAmountCents = 0,
    this.cancellationPolicy = const CancellationPolicy(),
    required this.createdAt,
    required this.updatedAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  bool get isUpcoming =>
      status == BookingStatus.confirmed &&
      checkIn.isAfter(DateTime.now());

  bool get isPast =>
      status == BookingStatus.completed ||
      (status == BookingStatus.confirmed && !checkIn.isAfter(DateTime.now()));

  bool get isCancelled => status == BookingStatus.cancelled;

  bool get isCancellable =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  int get addOnsTotalCents => price.addOnsTotalCents;
  int get totalCents => price.totalCents;

  Booking copyWith({
    BookingStatus? status,
    RefundStatus? refundStatus,
    int? refundAmountCents,
    DateTime? updatedAt,
  }) {
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
      addOns: addOns,
      specialRequests: specialRequests,
      paymentMethodId: paymentMethodId,
      refundStatus: refundStatus ?? this.refundStatus,
      refundAmountCents: refundAmountCents ?? this.refundAmountCents,
      cancellationPolicy: cancellationPolicy,
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
        'addOnsTotalCents': price.addOnsTotalCents,
        'nights': price.nights,
        'status': status.name,
        'bookingReference': bookingReference,
        'addOns': addOns.map((a) => a.toMap()).toList(),
        'specialRequests': specialRequests,
        'paymentMethodId': paymentMethodId,
        'refundStatus': refundStatus.name,
        'refundAmountCents': refundAmountCents,
        'cancellationPolicy': cancellationPolicy.toMap(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    final nights = (map['nights'] as num?)?.toInt() ?? 1;
    final nightlyPriceCents = (map['nightlyPriceCents'] as num?)?.toInt() ?? 0;
    final addOnsTotal = (map['addOnsTotalCents'] as num?)?.toInt() ?? 0;
    final rawAddOns = (map['addOns'] as List<dynamic>?) ?? [];
    final addOnsList = rawAddOns
        .map((a) => BookingAddOn.fromMap(Map<String, dynamic>.from(a as Map)))
        .toList();

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
        addOnsTotalCents: addOnsTotal,
      ),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      bookingReference: map['bookingReference'] as String? ?? '',
      addOns: addOnsList,
      specialRequests: map['specialRequests'] as String?,
      paymentMethodId: map['paymentMethodId'] as String?,
      refundStatus: RefundStatus.values.firstWhere(
        (r) => r.name == map['refundStatus'],
        orElse: () => RefundStatus.none,
      ),
      refundAmountCents: (map['refundAmountCents'] as num?)?.toInt() ?? 0,
      cancellationPolicy: map['cancellationPolicy'] != null
          ? CancellationPolicy.fromMap(
              Map<String, dynamic>.from(map['cancellationPolicy'] as Map))
          : const CancellationPolicy(),
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
  final List<BookingAddOn> addOns;
  final String? specialRequests;
  final String? paymentMethodId;
  final CancellationPolicy cancellationPolicy;

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
    this.addOns = const [],
    this.specialRequests,
    this.paymentMethodId,
    this.cancellationPolicy = const CancellationPolicy(),
  });

  int get nights => checkOut.difference(checkIn).inDays;

  int get addOnsTotalCents {
    final validNights = nights > 0 ? nights : 1;
    return addOns.fold<int>(
      0,
      (sum, item) => sum + item.calculateTotalCents(validNights),
    );
  }

  BookingPrice get price => BookingPrice.calculate(
        nightlyPriceCents: nightlyPriceCents,
        nights: nights,
        guests: guestCount,
        addOnsTotalCents: addOnsTotalCents,
      );
}

