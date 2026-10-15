/// Types of ledger transactions for points accounting.
enum PointsTransactionType {
  earned,
  redeemed,
  promotionalBonus,
  refundReversal,
  tierBonus,
}

/// A persistent, auditable transaction in the Veyra Points ledger.
class PointsTransaction {
  final String id;
  final PointsTransactionType type;
  final int pointsDelta;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? referenceId;

  const PointsTransaction({
    required this.id,
    required this.type,
    required this.pointsDelta,
    required this.title,
    required this.description,
    required this.timestamp,
    this.referenceId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'pointsDelta': pointsDelta,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'referenceId': referenceId,
      };

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'] as String? ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: PointsTransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PointsTransactionType.earned,
      ),
      pointsDelta: json['pointsDelta'] as int? ?? 0,
      title: json['title'] as String? ?? 'Points Activity',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      referenceId: json['referenceId'] as String?,
    );
  }
}

/// Loyalty tiers in Veyra's elite reward ecosystem.
enum VeyraTier {
  silver,
  gold,
  platinum,
  blackTier,
}

/// Mathematical rules, threshold curves, and earn formulas for Veyra Points.
class TierMath {
  static const int silverThreshold = 0;
  static const int goldThreshold = 2500;
  static const int platinumThreshold = 7500;
  static const int blackTierThreshold = 20000;

  /// Base earn multiplier: 5 Veyra points earned per USD/EUR spent.
  static const double baseEarnRate = 5.0;

  /// Calculates points earned for a given booking spend in integer cents.
  static int calculatePointsEarned(int spendCents, {VeyraTier tier = VeyraTier.blackTier}) {
    if (spendCents <= 0) return 0;
    final spendMajor = spendCents / 100.0;
    final tierMultiplier = switch (tier) {
      VeyraTier.silver => 1.0,
      VeyraTier.gold => 1.2,
      VeyraTier.platinum => 1.5,
      VeyraTier.blackTier => 2.0,
    };
    return (spendMajor * baseEarnRate * tierMultiplier).round();
  }

  /// Calculates tier based on lifetime points earned.
  static VeyraTier calculateTier(int lifetimePoints) {
    if (lifetimePoints >= blackTierThreshold) return VeyraTier.blackTier;
    if (lifetimePoints >= platinumThreshold) return VeyraTier.platinum;
    if (lifetimePoints >= goldThreshold) return VeyraTier.gold;
    return VeyraTier.silver;
  }

  /// Human-readable title for each tier.
  static String tierName(VeyraTier tier) {
    return switch (tier) {
      VeyraTier.silver => 'Veyra Silver Member',
      VeyraTier.gold => 'Veyra Gold Voyager',
      VeyraTier.platinum => 'Veyra Platinum Elite',
      VeyraTier.blackTier => 'Veyra Black Tier',
    };
  }

  /// Returns the next tier in progression, or null if highest tier achieved.
  static VeyraTier? nextTier(VeyraTier tier) {
    return switch (tier) {
      VeyraTier.silver => VeyraTier.gold,
      VeyraTier.gold => VeyraTier.platinum,
      VeyraTier.platinum => VeyraTier.blackTier,
      VeyraTier.blackTier => null,
    };
  }

  /// Threshold for a specific tier.
  static int tierThreshold(VeyraTier tier) {
    return switch (tier) {
      VeyraTier.silver => silverThreshold,
      VeyraTier.gold => goldThreshold,
      VeyraTier.platinum => platinumThreshold,
      VeyraTier.blackTier => blackTierThreshold,
    };
  }

  /// Mathematical progress percentage toward the next tier (0.0 to 1.0).
  static double calculateTierProgress(int lifetimePoints) {
    final currentTier = calculateTier(lifetimePoints);
    final upcomingTier = nextTier(currentTier);
    if (upcomingTier == null) return 1.0; // Max tier reached

    final currentMin = tierThreshold(currentTier);
    final targetMax = tierThreshold(upcomingTier);
    final progress = (lifetimePoints - currentMin) / (targetMax - currentMin);
    return progress.clamp(0.0, 1.0);
  }

  /// Exact points remaining to unlock the next prestige tier.
  static int pointsToNextTier(int lifetimePoints) {
    final currentTier = calculateTier(lifetimePoints);
    final upcomingTier = nextTier(currentTier);
    if (upcomingTier == null) return 0;

    final targetMax = tierThreshold(upcomingTier);
    final diff = targetMax - lifetimePoints;
    return diff > 0 ? diff : 0;
  }
}

/// Durable voucher redeemed through Veyra Points.
class RewardVoucher {
  final String id;
  final String title;
  final String code;
  final int pointsSpent;
  final int discountAmountCents;
  final DateTime redeemedAt;
  final DateTime expiresAt;
  final bool isUsed;

  const RewardVoucher({
    required this.id,
    required this.title,
    required this.code,
    required this.pointsSpent,
    required this.discountAmountCents,
    required this.redeemedAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'pointsSpent': pointsSpent,
        'discountAmountCents': discountAmountCents,
        'redeemedAt': redeemedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isUsed': isUsed,
      };

  factory RewardVoucher.fromJson(Map<String, dynamic> json) {
    return RewardVoucher(
      id: json['id'] as String? ?? 'v_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Reward Voucher',
      code: json['code'] as String? ?? 'VRA-DISCOUNT',
      pointsSpent: json['pointsSpent'] as int? ?? 0,
      discountAmountCents: json['discountAmountCents'] as int? ?? 0,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      isUsed: json['isUsed'] as bool? ?? false,
    );
  }
}
