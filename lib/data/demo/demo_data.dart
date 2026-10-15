import '../models/stay.dart';

/// Rich seeded demo data for Veyra — no network required.
/// Images sourced from publicly accessible Unsplash URLs (free to use).
abstract class DemoData {
  // ── Destinations ──────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> destinations = [
    {
      'id': 'dest_bora_bora',
      'name': 'Bora Bora',
      'country': 'French Polynesia',
      'subtitle': 'Overwater paradise',
      'imageUrl':
          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800',
      'isFeatured': true,
      'stayCount': 24,
    },
    {
      'id': 'dest_kyoto',
      'name': 'Kyoto',
      'country': 'Japan',
      'subtitle': 'Ancient temples & zen',
      'imageUrl':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
      'isFeatured': true,
      'stayCount': 38,
    },
    {
      'id': 'dest_santorini',
      'name': 'Santorini',
      'country': 'Greece',
      'subtitle': 'Caldera views & sunsets',
      'imageUrl':
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
      'isFeatured': true,
      'stayCount': 31,
    },
    {
      'id': 'dest_maldives',
      'name': 'Maldives',
      'country': 'Maldives',
      'subtitle': 'Crystal lagoons & reefs',
      'imageUrl':
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800',
      'isFeatured': false,
      'stayCount': 19,
    },
    {
      'id': 'dest_amalfi',
      'name': 'Amalfi Coast',
      'country': 'Italy',
      'subtitle': 'Dramatic cliffside beauty',
      'imageUrl':
          'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=800',
      'isFeatured': false,
      'stayCount': 27,
    },
    {
      'id': 'dest_dubai',
      'name': 'Dubai',
      'country': 'UAE',
      'subtitle': 'Ultra-luxury skyline stays',
      'imageUrl':
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
      'isFeatured': true,
      'stayCount': 44,
    },
  ];

  // ── Stays ─────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> stays = [
    // ── Bora Bora ──────────────────────────────────────────────────────────
    {
      'id': 's001',
      'title': 'Pearl Overwater Bungalow',
      'destinationId': 'dest_bora_bora',
      'destination': 'Bora Bora',
      'country': 'French Polynesia',
      'description':
          'Perched above the crystalline lagoon, this exclusive overwater bungalow offers unobstructed views of Mount Otemanu. Wake to the sound of gentle waves and step directly into warm, turquoise water. Private plunge pool, glass floor panels, and butler service included.',
      'nightlyPriceCents': 58000,
      'currency': 'USD',
      'rating': 4.9,
      'reviewCount': 312,
      'imageUrls': [
        'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=1200',
        'https://images.unsplash.com/photo-1439130490301-25e322d88054?w=1200',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Spa', 'Dining', 'Ocean', 'Butler', 'AC'],
      'hostName': 'Mara Hāpai',
      'hostAvatarUrl':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
      'maxGuests': 2,
      'isFeatured': true,
      'isActive': true,
      'category': 'Villa',
      'latitude': -16.5004,
      'longitude': -151.7415,
    },
    {
      'id': 's002',
      'title': 'Azure Beach Resort',
      'destinationId': 'dest_bora_bora',
      'destination': 'Bora Bora',
      'country': 'French Polynesia',
      'description':
          'A five-star resort nestled in tropical gardens with direct beach access, infinity pool, and world-class diving facilities.',
      'nightlyPriceCents': 42000,
      'currency': 'USD',
      'rating': 4.7,
      'reviewCount': 204,
      'imageUrls': [
        'https://images.unsplash.com/photo-1439130490301-25e322d88054?w=1200',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Spa', 'Dining', 'Beach', 'Gym'],
      'hostName': 'Te Ao Hāpai',
      'hostAvatarUrl': '',
      'maxGuests': 4,
      'isFeatured': false,
      'isActive': true,
      'category': 'Resort',
      'latitude': -16.4950,
      'longitude': -151.7350,
    },
    // ── Kyoto ──────────────────────────────────────────────────────────────
    {
      'id': 's003',
      'title': 'The Ritz-Carlton Kyoto',
      'destinationId': 'dest_kyoto',
      'destination': 'Kyoto',
      'country': 'Japan',
      'description':
          'The Ritz-Carlton, Kyoto is an extraordinary luxury retreat on the banks of the Kamogawa River. The hotel blends traditional Japanese aesthetics with contemporary elegance, offering rooms with panoramic river and garden views.',
      'nightlyPriceCents': 82000,
      'currency': 'USD',
      'rating': 5.0,
      'reviewCount': 528,
      'imageUrls': [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200',
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1200',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200',
      ],
      'amenities': ['Spa', 'Dining', 'Gym', 'Pool', 'Wifi', 'AC', 'Bar'],
      'hostName': 'Yuki Tanaka',
      'hostAvatarUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      'maxGuests': 3,
      'isFeatured': true,
      'isActive': true,
      'category': 'Hotel',
      'latitude': 35.0116,
      'longitude': 135.7681,
    },
    {
      'id': 's004',
      'title': 'Arashiyama Bamboo Ryokan',
      'destinationId': 'dest_kyoto',
      'destination': 'Kyoto',
      'country': 'Japan',
      'description':
          'An authentic Japanese ryokan tucked beside the iconic bamboo grove. Experience kaiseki dining, traditional onsen baths, and tatami-floored rooms.',
      'nightlyPriceCents': 32000,
      'currency': 'USD',
      'rating': 4.8,
      'reviewCount': 189,
      'imageUrls': [
        'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?w=1200',
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1200',
      ],
      'amenities': ['Onsen', 'Dining', 'Wifi', 'Garden', 'AC'],
      'hostName': 'Kenji Mori',
      'hostAvatarUrl': '',
      'maxGuests': 2,
      'isFeatured': false,
      'isActive': true,
      'category': 'Villa',
      'latitude': 35.0150,
      'longitude': 135.6720,
    },
    // ── Santorini ──────────────────────────────────────────────────────────
    {
      'id': 's005',
      'title': 'Caldera Cliff Suite',
      'destinationId': 'dest_santorini',
      'destination': 'Santorini',
      'country': 'Greece',
      'description':
          'Carved into the volcanic caldera cliff, this suite offers an iconic infinity pool overlooking the Aegean Sea. Watch breathtaking sunsets from your private terrace.',
      'nightlyPriceCents': 67000,
      'currency': 'USD',
      'rating': 4.9,
      'reviewCount': 267,
      'imageUrls': [
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=1200',
        'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=1200',
        'https://images.unsplash.com/photo-1602343168117-bb8ffe3e2e9f?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Breakfast', 'Spa', 'Ocean', 'Bar'],
      'hostName': 'Elena Papadopoulos',
      'hostAvatarUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'maxGuests': 2,
      'isFeatured': true,
      'isActive': true,
      'category': 'Villa',
      'latitude': 36.4618,
      'longitude': 25.3753,
    },
    {
      'id': 's006',
      'title': 'Oia Luxury Cave Hotel',
      'destinationId': 'dest_santorini',
      'destination': 'Santorini',
      'country': 'Greece',
      'description':
          'Whitewashed cave rooms in the village of Oia with spectacular caldera views and award-winning Cycladic cuisine.',
      'nightlyPriceCents': 38000,
      'currency': 'USD',
      'rating': 4.6,
      'reviewCount': 143,
      'imageUrls': [
        'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=1200',
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=1200',
      ],
      'amenities': ['Wifi', 'Dining', 'Bar', 'Ocean', 'Breakfast'],
      'hostName': 'Nikos Alexiou',
      'hostAvatarUrl': '',
      'maxGuests': 2,
      'isFeatured': false,
      'isActive': true,
      'category': 'Hotel',
      'latitude': 36.4630,
      'longitude': 25.3780,
    },
    // ── Maldives ──────────────────────────────────────────────────────────
    {
      'id': 's007',
      'title': 'Crystal Lagoon Water Villa',
      'destinationId': 'dest_maldives',
      'destination': 'Maldives',
      'country': 'Maldives',
      'description':
          'A secluded water villa above a pristine coral reef. Features a glass-floor lounge, private snorkeling access, and a curved sun deck.',
      'nightlyPriceCents': 52000,
      'currency': 'USD',
      'rating': 4.9,
      'reviewCount': 398,
      'imageUrls': [
        'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=1200',
        'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Spa', 'Diving', 'Ocean', 'Bar'],
      'hostName': 'Ahmed Rashid',
      'hostAvatarUrl': '',
      'maxGuests': 3,
      'isFeatured': false,
      'isActive': true,
      'category': 'Villa',
      'latitude': 3.2028,
      'longitude': 73.2207,
    },
    // ── Amalfi ────────────────────────────────────────────────────────────
    {
      'id': 's008',
      'title': 'Cliffside Amalfi Retreat',
      'destinationId': 'dest_amalfi',
      'destination': 'Amalfi Coast',
      'country': 'Italy',
      'description':
          'A historic villa perched above the Mediterranean with lemon terraces, an antique mosaic pool, and panoramic views of the Tyrrhenian Sea.',
      'nightlyPriceCents': 44000,
      'currency': 'USD',
      'rating': 4.8,
      'reviewCount': 211,
      'imageUrls': [
        'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=1200',
        'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Dining', 'Garden', 'Ocean', 'Spa'],
      'hostName': 'Marco Esposito',
      'hostAvatarUrl': '',
      'maxGuests': 6,
      'isFeatured': false,
      'isActive': true,
      'category': 'Villa',
      'latitude': 40.6340,
      'longitude': 14.6027,
    },
    // ── Dubai ─────────────────────────────────────────────────────────────
    {
      'id': 's009',
      'title': 'Burj View Sky Suite',
      'destinationId': 'dest_dubai',
      'destination': 'Dubai',
      'country': 'UAE',
      'description':
          'A penthouse-level suite with panoramic views of the Burj Khalifa, private chef access, a rooftop infinity pool, and dedicated concierge.',
      'nightlyPriceCents': 95000,
      'currency': 'USD',
      'rating': 5.0,
      'reviewCount': 87,
      'imageUrls': [
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200',
        'https://images.unsplash.com/photo-1548199569-3e1c6aa8f469?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Gym', 'Dining', 'Bar', 'Spa', 'Butler', 'AC'],
      'hostName': 'Khalid Al Rashid',
      'hostAvatarUrl': '',
      'maxGuests': 4,
      'isFeatured': true,
      'isActive': true,
      'category': 'Hotel',
      'latitude': 25.1972,
      'longitude': 55.2744,
    },
    {
      'id': 's010',
      'title': 'Desert Rose Palm Villa',
      'destinationId': 'dest_dubai',
      'destination': 'Dubai',
      'country': 'UAE',
      'description':
          'A luxurious private villa on the Palm Jumeirah with a private beach, heated pool, and unobstructed views of the Dubai skyline.',
      'nightlyPriceCents': 76000,
      'currency': 'USD',
      'rating': 4.8,
      'reviewCount': 154,
      'imageUrls': [
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=1200',
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200',
      ],
      'amenities': ['Pool', 'Wifi', 'Beach', 'Gym', 'Bar', 'AC', 'Dining'],
      'hostName': 'Fatima Hassan',
      'hostAvatarUrl': '',
      'maxGuests': 8,
      'isFeatured': false,
      'isActive': true,
      'category': 'Villa',
      'latitude': 25.1124,
      'longitude': 55.1390,
    },
  ];

  /// Parse all stays into [Stay] objects.
  static List<Stay> get allStays =>
      stays.map((m) => Stay.fromMap(Map<String, dynamic>.from(m), m['id'] as String)).toList();

  static List<Stay> get featuredStays =>
      allStays.where((s) => s.isFeatured).toList();

  static Stay? stayById(String id) {
    try {
      return allStays.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────
  static const List<String> categories = [
    'All',
    'Hotel',
    'Villa',
    'Resort',
    'Apartment',
  ];
}
