/// Stay model — represents an accommodation listing.
class Stay {
  final String id;
  final String title;
  final String destinationId;
  final String destination;
  final String country;
  final String description;
  final int nightlyPriceCents; // stored in cents for safety
  final String currency;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> amenities;
  final String hostName;
  final String hostAvatarUrl;
  final int maxGuests;
  final bool isFeatured;
  final bool isActive;
  final String category; // 'Hotel' | 'Villa' | 'Resort' | 'Apartment'
  final double? latitude;
  final double? longitude;

  const Stay({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.destination,
    required this.country,
    required this.description,
    required this.nightlyPriceCents,
    this.currency = 'USD',
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.amenities,
    required this.hostName,
    this.hostAvatarUrl = '',
    required this.maxGuests,
    this.isFeatured = false,
    this.isActive = true,
    this.category = 'Hotel',
    this.latitude,
    this.longitude,
  });

  /// Nightly price as a display string (e.g. "$420").
  String get nightlyPriceDisplay =>
      '\$${(nightlyPriceCents / 100).toStringAsFixed(0)}';

  double get nightlyPrice => nightlyPriceCents / 100.0;

  String get primaryImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : '';

  Stay copyWith({
    String? id,
    String? title,
    String? destinationId,
    String? destination,
    String? country,
    String? description,
    int? nightlyPriceCents,
    String? currency,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? amenities,
    String? hostName,
    String? hostAvatarUrl,
    int? maxGuests,
    bool? isFeatured,
    bool? isActive,
    String? category,
    double? latitude,
    double? longitude,
  }) {
    return Stay(
      id: id ?? this.id,
      title: title ?? this.title,
      destinationId: destinationId ?? this.destinationId,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      description: description ?? this.description,
      nightlyPriceCents: nightlyPriceCents ?? this.nightlyPriceCents,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      maxGuests: maxGuests ?? this.maxGuests,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Stay.fromMap(Map<String, dynamic> map, String docId) {
    return Stay(
      id: docId,
      title: map['title'] as String? ?? '',
      destinationId: map['destinationId'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      country: map['country'] as String? ?? '',
      description: map['description'] as String? ?? '',
      nightlyPriceCents: (map['nightlyPriceCents'] as num?)?.toInt() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      amenities: List<String>.from(map['amenities'] as List? ?? []),
      hostName: map['hostName'] as String? ?? '',
      hostAvatarUrl: map['hostAvatarUrl'] as String? ?? '',
      maxGuests: (map['maxGuests'] as num?)?.toInt() ?? 2,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      category: map['category'] as String? ?? 'Hotel',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'destinationId': destinationId,
        'destination': destination,
        'country': country,
        'description': description,
        'nightlyPriceCents': nightlyPriceCents,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageUrls': imageUrls,
        'amenities': amenities,
        'hostName': hostName,
        'hostAvatarUrl': hostAvatarUrl,
        'maxGuests': maxGuests,
        'isFeatured': isFeatured,
        'isActive': isActive,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Destination model — represents a travel destination.
class Destination {
  final String id;
  final String name;
  final String country;
  final String subtitle;
  final String imageUrl;
  final bool isFeatured;
  final int stayCount;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.subtitle,
    required this.imageUrl,
    this.isFeatured = false,
    this.stayCount = 0,
  });

  factory Destination.fromMap(Map<String, dynamic> map, String docId) {
    return Destination(
      id: docId,
      name: map['name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      isFeatured: map['isFeatured'] as bool? ?? false,
      stayCount: (map['stayCount'] as num?)?.toInt() ?? 0,
    );
  }
}
