import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veyra/data/models/points_ledger.dart';
import 'package:veyra/data/models/booking.dart';
import 'package:veyra/data/repositories/demo_repository.dart';

void main() {
  group('Veyra TierMath & Loyalty Ledger Mathematics', () {
    test('Calculates tier classification across all prestige thresholds correctly', () {
      expect(TierMath.calculateTier(0), equals(VeyraTier.silver));
      expect(TierMath.calculateTier(2499), equals(VeyraTier.silver));
      expect(TierMath.calculateTier(2500), equals(VeyraTier.gold));
      expect(TierMath.calculateTier(7499), equals(VeyraTier.gold));
      expect(TierMath.calculateTier(7500), equals(VeyraTier.platinum));
      expect(TierMath.calculateTier(19999), equals(VeyraTier.platinum));
      expect(TierMath.calculateTier(20000), equals(VeyraTier.blackTier));
      expect(TierMath.calculateTier(100000), equals(VeyraTier.blackTier));
    });

    test('Computes tier progression percentage mathematically', () {
      // Silver tier: 0 to 2500
      expect(TierMath.calculateTierProgress(0), equals(0.0));
      expect(TierMath.calculateTierProgress(1250), closeTo(0.5, 0.001));

      // Gold tier: 2500 to 7500 (span = 5000)
      expect(TierMath.calculateTierProgress(2500), equals(0.0));
      expect(TierMath.calculateTierProgress(5000), closeTo(0.5, 0.001));

      // Black tier: apex level (always 1.0)
      expect(TierMath.calculateTierProgress(20000), equals(1.0));
      expect(TierMath.calculateTierProgress(50000), equals(1.0));
    });

    test('Calculates exact points required to unlock next tier', () {
      expect(TierMath.pointsToNextTier(1000), equals(1500));
      expect(TierMath.pointsToNextTier(2500), equals(5000));
      expect(TierMath.pointsToNextTier(20000), equals(0));
    });

    test('Calculates earn points based on booking spend and tier multiplier', () {
      // $1,000 spend (100,000 cents = 1000 USD major)
      // Base rate = 5.0 points per USD
      final silverEarn = TierMath.calculatePointsEarned(100000, tier: VeyraTier.silver);
      expect(silverEarn, equals(5000)); // 1000 * 5 * 1.0

      final blackTierEarn = TierMath.calculatePointsEarned(100000, tier: VeyraTier.blackTier);
      expect(blackTierEarn, equals(10000)); // 1000 * 5 * 2.0
    });

    test('Serializes and deserializes PointsTransaction and RewardVoucher', () {
      final tx = PointsTransaction(
        id: 'tx_unit_1',
        type: PointsTransactionType.earned,
        pointsDelta: 2500,
        title: 'Villa Stay',
        description: 'Earned 2,500 pts',
        timestamp: DateTime(2026, 6, 15),
        referenceId: 'VYR-7788',
      );

      final json = tx.toJson();
      final restored = PointsTransaction.fromJson(json);

      expect(restored.id, equals('tx_unit_1'));
      expect(restored.type, equals(PointsTransactionType.earned));
      expect(restored.pointsDelta, equals(2500));
      expect(restored.referenceId, equals('VYR-7788'));

      final voucher = RewardVoucher(
        id: 'vouch_1',
        title: 'Spa Access',
        code: 'SPA-8849',
        pointsSpent: 1500,
        discountAmountCents: 15000,
        redeemedAt: DateTime(2026, 6, 15),
        expiresAt: DateTime(2026, 12, 31),
      );

      final vJson = voucher.toJson();
      final restoredVoucher = RewardVoucher.fromJson(vJson);
      expect(restoredVoucher.code, equals('SPA-8849'));
      expect(restoredVoucher.pointsSpent, equals(1500));
      expect(restoredVoucher.discountAmountCents, equals(15000));
      expect(restoredVoucher.isValid, isTrue);
    });
  });

  group('Booking & Add-on Calculations', () {
    test('Calculates add-on subtotal and total booking amount accurately', () {
      final addOns = [
        const BookingAddOn(
          id: 'champagne',
          title: 'Dom Pérignon 2013',
          subtitle: 'Chilled bottle placed in suite',
          priceCents: 45000,
          isPerNight: false,
        ),
        const BookingAddOn(
          id: 'helicopter',
          title: 'Airport Helicopter Transfer',
          subtitle: 'Round-trip executive transfer',
          priceCents: 125000,
          isPerNight: false,
        ),
      ];

      final now = DateTime.now();
      final booking = Booking(
        id: 'bk_1',
        userId: 'user_1',
        stayId: 'stay_aman',
        stayTitle: 'Aman Tokyo',
        stayImageUrl: 'https://example.com/aman.jpg',
        destination: 'Tokyo, Japan',
        checkIn: now.add(const Duration(days: 10)),
        checkOut: now.add(const Duration(days: 15)),
        guestCount: 2,
        price: BookingPrice.calculate(
          nightlyPriceCents: 200000,
          nights: 5,
          guests: 2,
          addOnsTotalCents: 45000 + 125000,
        ),
        status: BookingStatus.confirmed,
        bookingReference: 'VYR-UNIT',
        createdAt: now,
        updatedAt: now,
        addOns: addOns,
        cancellationPolicy: const CancellationPolicy(),
        refundStatus: RefundStatus.none,
      );

      expect(booking.addOnsTotalCents, equals(45000 + 125000));
      expect(booking.isUpcoming, isTrue);
      expect(booking.isPast, isFalse);
      expect(booking.isCancelled, isFalse);
    });

    test('Correctly identifies cancelled booking lifecycle and refund status', () {
      final now = DateTime.now();
      final cancelledBooking = Booking(
        id: 'bk_2',
        userId: 'user_1',
        stayId: 'stay_2',
        stayTitle: 'Lake Como Villa',
        stayImageUrl: 'https://example.com/como.jpg',
        destination: 'Lake Como, Italy',
        checkIn: now.add(const Duration(days: 5)),
        checkOut: now.add(const Duration(days: 8)),
        guestCount: 2,
        price: BookingPrice.calculate(
          nightlyPriceCents: 150000,
          nights: 3,
        ),
        status: BookingStatus.cancelled,
        bookingReference: 'VYR-CANCEL',
        createdAt: now,
        updatedAt: now,
        refundStatus: RefundStatus.refunded,
        refundAmountCents: 500000,
      );

      expect(cancelledBooking.isCancelled, isTrue);
      expect(cancelledBooking.isUpcoming, isFalse);
      expect(cancelledBooking.isPast, isFalse);
      expect(cancelledBooking.refundStatus, equals(RefundStatus.refunded));
      expect(cancelledBooking.refundAmountCents, equals(500000));
    });
  });

  group('DemoSavedRepository Multi-User Isolation', () {
    test('Ensures favorites are strictly isolated per authenticated user ID', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = DemoSavedRepository();

      await repo.toggleSavedStay(userId: 'user_alpha', stayId: 'stay_101');
      await repo.toggleSavedStay(userId: 'user_alpha', stayId: 'stay_102');

      await repo.toggleSavedStay(userId: 'user_beta', stayId: 'stay_201');

      final alphaSaved = await repo.streamSavedStayIds('user_alpha').first;
      final betaSaved = await repo.streamSavedStayIds('user_beta').first;

      expect(alphaSaved, containsAll(['stay_101', 'stay_102']));
      expect(alphaSaved, isNot(contains('stay_201')));

      expect(betaSaved, contains('stay_201'));
      expect(betaSaved, isNot(contains('stay_101')));

      await repo.dispose();
    });
  });
}
