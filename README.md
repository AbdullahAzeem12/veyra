# Veyra — Luxury Travel & Stay Explorer 🌴✨

**Veyra** is a state-of-the-art Flutter mobile application engineered for discovering, previewing, and reserving world-class luxury stays, private villas, overwater bungalows, and historic châteaux.

---

## 🏛 Architecture & Engineering Foundations

Veyra is structured on clean architectural seams with **ChangeNotifier**, custom **AppScope** inherited injection, and repository boundaries separating presentation from business logic and data providers:

```
lib/
├── core/
│   ├── biometrics/          # Local device biometric authentication (Face ID / Fingerprint)
│   ├── localization/        # 8-language multilingual translation dictionary & RTL helpers
│   ├── navigation/          # Route generation, fade/slide route transitions
│   ├── responsive/          # AdaptiveScaffold & Liquid Glass floating dock navigation
│   ├── scope/               # AppScope dependency injection & CurrencyController
│   ├── services/            # AlertService (VIP notifications & quiet-hours management)
│   ├── storage/             # VeyraStorageService (SharedPreferences & Secure storage seams)
│   ├── theme/               # Design tokens (Pearl, Deep Emerald, Antique Gold) & ThemeController
│   ├── utils/               # Booking validation & integer-cent price calculation
│   └── widgets/             # VeyraGlassSurface, VeyraPressable, Shimmer skeletons, StayCard
├── data/
│   ├── demo/                # Seeded curated luxury stay catalog & destinations
│   ├── models/              # Stay, Booking, BookingAddOn, PointsLedger, SearchCriteria
│   └── repositories/        # StayRepository, SavedRepository, BookingRepository
└── features/
    ├── explore/             # Hero, Category filters, Featured carousel, Curated destinations
    ├── search/              # Debounced query, persistent recent searches, interactive preview map
    ├── saved/               # Isolated user collections with optimistic toggle & rollback
    ├── trips/               # Upcoming, Completed, and Cancelled trips with refund tracking
    ├── stay_details/        # Hero image gallery, stay highlights, amenities, and booking wizard
    └── profile/             # Profile management, camera/gallery avatar upload, VIP tier ledger
```

---

## 💎 Liquid Glass Morphism & Physics Motion System

Veyra incorporates a physics-driven, responsive interaction system:

1. **Liquid Glass Morphism (`VeyraGlassSurface`)**:
   - Multi-layered specular highlights with optical backdrop blur (`ImageFilter.blur`).
   - Dual-border rim lighting (0.5–1.2px) simulating light refraction on real glass.
   - Six specialized semantic presets: `subtle`, `standard`, `floating`, `navigation`, `modal`, and `premium`.
   - Contrast-preserving tinting for seamless dark mode (`obsidian` / `forestSlate`) and light mode (`pearlIvory`).

2. **Spring Physics & Press Feedback (`VeyraPressable`)**:
   - Realistic micro-scale compression (`0.965`) with `Curves.easeOutBack` spring rebound.
   - Native haptic feedback (`HapticFeedback.lightImpact`) on tap.
   - Pointer-driven dynamic 3D matrix transformations for luxury stay cards (`Matrix4.diagonal3Values`).

3. **Liquid Glass Navigation Dock**:
   - Floating dock with blur, specular rim, and antique gold indicator bar.
   - Spring scaling animations on active navigation icons.

---

## 🧮 Mathematics & Physics Engine

Veyra replaces fake counters and static tiers with genuine business logic:

1. **Integer Minor-Unit Money Calculations**:
   - All prices, fees, and taxes are strictly handled in integer cents (`int cents`) to eliminate floating-point rounding errors.
   - Comprehensive quotes include: Nightly Subtotal, 10% Cleaning Fee, 12% Service Fee, 15% Multi-night Discount, 8% Regulatory Tax, and selected luxury add-ons (Helicopter, Dom Pérignon, Butler, Yacht).

2. **Auditable Veyra Points Ledger (`PointsLedger`)**:
   - Append-only transactional history (`PointsTransaction`) tracking earned, redeemed, promotional, and tier bonus points.
   - Dynamic tier progression calculated mathematically through `TierMath`:
     - **Veyra Silver Member**: 0 – 2,499 pts (1.0x earn multiplier)
     - **Veyra Gold Voyager**: 2,500 – 7,499 pts (1.2x earn multiplier)
     - **Veyra Platinum Elite**: 7,500 – 19,999 pts (1.5x earn multiplier)
     - **Veyra Black Tier**: 20,000+ pts (2.0x earn multiplier)
   - Real-time tier progress bar (`tierProgress` 0.0 to 1.0) and exact countdown to the next prestige tier.
   - Atomic redemption producing unique, persistent `RewardVoucher` certificates.

3. **Authoritative Booking & Refund Lifecycle**:
   - Strict state machine: `pending` → `confirmed` → `completed` or `cancelled`.
   - Distinct cancellation and refund statuses: `none`, `pending`, `refunded`, `nonRefundable`.
   - Trips screen features dedicated, independent tabs: **Upcoming**, **Completed**, and **Cancelled** (with refund audit trails).

---

## 📸 Real Photo Upload & Profile Management

- Profile avatar supports real device image selection via `image_picker` (Camera and Photo Library).
- Automatic client-side validation (format verification and 5MB size limit).
- Encoded into Base64 data URIs for immediate local persistence, with fallback to remote image providers via `avatarImageProvider`.

---

## 🔒 Security & Privacy Practices

- **Zero PAN/CVV Retention**: Only opaque payment method tokens and safe display metadata (`brand`, `last4`, `expiry`) are persisted.
- **Biometric Protection**: Biometric gates (`local_auth`) protect payment authorization and sensitive preference updates.
- **User-Scoped Isolation**: Favorites, bookings, and vouchers are strictly indexed by authenticated user ID (`_savedMap[userId]`), preventing data leakage across accounts.
- **Network Permissions**: Declared `<uses-permission android:name="android.permission.INTERNET"/>` in `android/app/src/main/AndroidManifest.xml` for production releases.

---

## 🧪 Testing & Verification

The test suite validates both domain mathematics and widget rendering:

```bash
# Run complete test suite (17 passed)
flutter test

# Run domain mathematics tests (TierMath, Ledger, Booking, Isolation)
flutter test test/veyra_test.dart

# Run widget interaction tests (Navigation, Search, Sheets, Shimmer)
flutter test test/widget_test.dart

# Static analysis (0 warnings / 0 errors)
flutter analyze
```

---

## 🚀 Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run in Debug Mode**:
   ```bash
   flutter run
   ```

3. **Build Android Release**:
   ```bash
   flutter build apk --release
   ```
