import 'package:flutter/foundation.dart';
import '../../core/storage/veyra_storage_service.dart';

import '../../data/models/points_ledger.dart';
export '../../data/models/points_ledger.dart';

class PaymentCard {
  final String id;
  final String brand; // 'Mastercard', 'Visa', 'Amex'
  final String last4;
  final String expiry;
  final String cardholder;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.cardholder,
    this.isDefault = false,
  });

  PaymentCard copyWith({bool? isDefault}) {
    return PaymentCard(
      id: id,
      brand: brand,
      last4: last4,
      expiry: expiry,
      cardholder: cardholder,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class DeviceSession {
  final String id;
  final String deviceName;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceName': deviceName,
        'location': location,
        'lastActive': lastActive,
        'isCurrent': isCurrent,
      };

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: json['id'] as String? ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      deviceName: json['deviceName'] as String? ?? 'Device',
      location: json['location'] as String? ?? 'Unknown Location',
      lastActive: json['lastActive'] as String? ?? 'Recently',
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }
}

class UserProfileController extends ChangeNotifier {
  String _name = 'Alexander Wright';
  final String _email = 'alexander.wright@veyra.travel';
  String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
  int _points = 24850;

  // Language
  String _language = 'English (US)';

  // Notifications
  bool _priceDropAlerts = true;
  bool _bookingUpdates = true;
  bool _conciergeExclusives = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _quietHoursEnabled = false;

  // Security
  bool _biometricsEnabled = true;
  bool _twoFactorEnabled = false;

  // Saved Payment Methods
  List<PaymentCard> _paymentCards = [
    const PaymentCard(
      id: 'card_1',
      brand: 'Mastercard',
      last4: '4821',
      expiry: '12/28',
      cardholder: 'ALEXANDER WRIGHT',
      isDefault: true,
    ),
    const PaymentCard(
      id: 'card_2',
      brand: 'Visa Infinite',
      last4: '9012',
      expiry: '09/27',
      cardholder: 'ALEXANDER WRIGHT',
      isDefault: false,
    ),
  ];

  // Active Device Sessions
  List<DeviceSession> _sessions = [
    const DeviceSession(
      id: 'session_1',
      deviceName: 'iPhone 16 Pro Max',
      location: 'Dubai, UAE',
      lastActive: 'Active Now',
      isCurrent: true,
    ),
    const DeviceSession(
      id: 'session_2',
      deviceName: 'MacBook Pro M3 Max',
      location: 'Paris, France',
      lastActive: 'Yesterday, 18:40',
      isCurrent: false,
    ),
    const DeviceSession(
      id: 'session_3',
      deviceName: 'iPad Pro 13"',
      location: 'Tokyo, Japan',
      lastActive: '3 days ago',
      isCurrent: false,
    ),
  ];

  // Redeemed Vouchers
  List<RewardVoucher> _vouchers = [];

  // Auditable Points Ledger
  List<PointsTransaction> _pointsLedger = [];

  UserProfileController() {
    loadFromStorage();
  }

  void loadFromStorage() {
    _name = VeyraStorageService.getUserName(fallback: _name);
    _avatarUrl = VeyraStorageService.getUserAvatar(fallback: _avatarUrl);
    _language = VeyraStorageService.getLanguage(fallback: _language);
    _priceDropAlerts = VeyraStorageService.getPriceDropAlerts(fallback: _priceDropAlerts);
    _bookingUpdates = VeyraStorageService.getBookingUpdates(fallback: _bookingUpdates);
    _conciergeExclusives = VeyraStorageService.getConciergeExclusives(fallback: _conciergeExclusives);
    _pushNotifications = VeyraStorageService.getPushNotifications(fallback: _pushNotifications);
    _emailNotifications = VeyraStorageService.getEmailNotifications(fallback: _emailNotifications);
    _smsNotifications = VeyraStorageService.getSmsNotifications(fallback: _smsNotifications);
    _quietHoursEnabled = VeyraStorageService.getQuietHours(fallback: _quietHoursEnabled);
    _biometricsEnabled = VeyraStorageService.getBiometricsEnabled(fallback: _biometricsEnabled);
    _twoFactorEnabled = VeyraStorageService.getTwoFactorEnabled(fallback: _twoFactorEnabled);
    _points = VeyraStorageService.getPoints(fallback: _points);

    // Load ledger
    final storedLedger = VeyraStorageService.getPointsLedger();
    if (storedLedger != null && storedLedger.isNotEmpty) {
      _pointsLedger = storedLedger.map((m) => PointsTransaction.fromJson(m)).toList();
    } else {
      // Seed initial ledger transactions reflecting member history
      _pointsLedger = [
        PointsTransaction(
          id: 'tx_seed_1',
          type: PointsTransactionType.earned,
          pointsDelta: 12500,
          title: 'Aman Tokyo Penthouse Stay',
          description: 'Completed 5-night stay · 5x Points Multiplier',
          timestamp: DateTime.now().subtract(const Duration(days: 42)),
          referenceId: 'VYR-8921',
        ),
        PointsTransaction(
          id: 'tx_seed_2',
          type: PointsTransactionType.tierBonus,
          pointsDelta: 5000,
          title: 'Black Tier Elite Welcome Bonus',
          description: 'Prestige tier attainment celebration grant',
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
        ),
        PointsTransaction(
          id: 'tx_seed_3',
          type: PointsTransactionType.earned,
          pointsDelta: 7350,
          title: 'Le Sirenuse Positano Suite',
          description: 'Completed 3-night stay · Emerald VIP Perks',
          timestamp: DateTime.now().subtract(const Duration(days: 12)),
          referenceId: 'VYR-4410',
        ),
      ];
      _savePointsLedger();
    }

    // Load vouchers
    final storedVouchers = VeyraStorageService.getRewardVouchers();
    if (storedVouchers != null && storedVouchers.isNotEmpty) {
      _vouchers = storedVouchers.map((m) => RewardVoucher.fromJson(m)).toList();
    }

    // Load sessions
    final storedSessions = VeyraStorageService.getDeviceSessions();
    if (storedSessions != null && storedSessions.isNotEmpty) {
      _sessions = storedSessions.map((m) => DeviceSession.fromJson(m)).toList();
    }

    final storedCards = VeyraStorageService.getPaymentCards();
    if (storedCards != null && storedCards.isNotEmpty) {
      _paymentCards = storedCards.map((c) => PaymentCard(
        id: c['id'] as String? ?? 'card_${DateTime.now().millisecondsSinceEpoch}',
        brand: c['brand'] as String? ?? 'Mastercard',
        last4: c['last4'] as String? ?? '0000',
        expiry: c['expiry'] as String? ?? '12/28',
        cardholder: c['cardholder'] as String? ?? 'ALEXANDER WRIGHT',
        isDefault: c['isDefault'] as bool? ?? false,
      )).toList();
    }
  }

  // Getters
  String get name => _name;
  String get email => _email;
  String get avatarUrl => _avatarUrl;
  int get points => _points;

  /// Dynamic loyalty tier calculated mathematically from total points earned
  int get lifetimePoints => _pointsLedger
      .where((t) => t.pointsDelta > 0)
      .fold(0, (sum, t) => sum + t.pointsDelta);

  VeyraTier get tierEnum => TierMath.calculateTier(lifetimePoints > 0 ? lifetimePoints : _points);
  String get tier => TierMath.tierName(tierEnum);
  double get tierProgress => TierMath.calculateTierProgress(lifetimePoints > 0 ? lifetimePoints : _points);
  int get pointsToNextTier => TierMath.pointsToNextTier(lifetimePoints > 0 ? lifetimePoints : _points);
  VeyraTier? get nextTier => TierMath.nextTier(tierEnum);

  String get language => _language;
  bool get priceDropAlerts => _priceDropAlerts;
  bool get bookingUpdates => _bookingUpdates;
  bool get conciergeExclusives => _conciergeExclusives;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get quietHoursEnabled => _quietHoursEnabled;

  bool get biometricsEnabled => _biometricsEnabled;
  bool get twoFactorEnabled => _twoFactorEnabled;

  List<PaymentCard> get paymentCards => List.unmodifiable(_paymentCards);
  List<DeviceSession> get sessions => List.unmodifiable(_sessions);
  List<RewardVoucher> get vouchers => List.unmodifiable(_vouchers);
  List<PointsTransaction> get pointsLedger => List.unmodifiable(_pointsLedger);

  PaymentCard? get defaultCard {
    for (final c in _paymentCards) {
      if (c.isDefault) return c;
    }
    return _paymentCards.isNotEmpty ? _paymentCards.first : null;
  }

  // Actions
  void updateAvatar(String newUrl) {
    _avatarUrl = newUrl;
    VeyraStorageService.setUserAvatar(newUrl);
    notifyListeners();
  }

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) {
      _name = newName.trim();
      VeyraStorageService.setUserName(_name);
      notifyListeners();
    }
  }

  void _savePointsLedger() {
    final list = _pointsLedger.map((tx) => tx.toJson()).toList();
    VeyraStorageService.setPointsLedger(list);
  }

  void _saveVouchers() {
    final list = _vouchers.map((v) => v.toJson()).toList();
    VeyraStorageService.setRewardVouchers(list);
  }

  void _saveSessions() {
    final list = _sessions.map((s) => s.toJson()).toList();
    VeyraStorageService.setDeviceSessions(list);
  }

  /// Records points earned through a verified booking or promotion.
  void recordPointsEarned({
    required String title,
    required String description,
    required int points,
    String? referenceId,
  }) {
    if (points <= 0) return;
    _points += points;
    VeyraStorageService.setPoints(_points);

    final tx = PointsTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: PointsTransactionType.earned,
      pointsDelta: points,
      title: title,
      description: description,
      timestamp: DateTime.now(),
      referenceId: referenceId,
    );
    _pointsLedger.insert(0, tx);
    _savePointsLedger();
    notifyListeners();
  }

  /// Atomically redeems rewards, debits ledger, and saves durable voucher.
  bool redeemReward(String title, int pointsCost, {int discountAmountCents = 15000}) {
    if (_points >= pointsCost) {
      _points -= pointsCost;
      VeyraStorageService.setPoints(_points);

      final code = 'VRA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final voucher = RewardVoucher(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        code: code,
        pointsSpent: pointsCost,
        discountAmountCents: discountAmountCents,
        redeemedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 365)),
      );
      _vouchers.insert(0, voucher);
      _saveVouchers();

      final tx = PointsTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: PointsTransactionType.redeemed,
        pointsDelta: -pointsCost,
        title: 'Redeemed: $title',
        description: 'Voucher code: $code · Valid for 1 year',
        timestamp: DateTime.now(),
        referenceId: voucher.id,
      );
      _pointsLedger.insert(0, tx);
      _savePointsLedger();

      notifyListeners();
      return true;
    }
    return false;
  }

  void _savePaymentCards() {
    final list = _paymentCards.map((c) => {
      'id': c.id,
      'brand': c.brand,
      'last4': c.last4,
      'expiry': c.expiry,
      'cardholder': c.cardholder,
      'isDefault': c.isDefault,
    }).toList();
    VeyraStorageService.setPaymentCards(list);
  }

  void addPaymentCard({
    required String brand,
    required String last4,
    required String expiry,
    required String cardholder,
    bool setAsDefault = false,
  }) {
    final newId = 'card_${DateTime.now().millisecondsSinceEpoch}';
    if (setAsDefault || _paymentCards.isEmpty) {
      _paymentCards = _paymentCards.map((c) => c.copyWith(isDefault: false)).toList();
    }
    _paymentCards.add(
      PaymentCard(
        id: newId,
        brand: brand,
        last4: last4,
        expiry: expiry,
        cardholder: cardholder.toUpperCase(),
        isDefault: setAsDefault || _paymentCards.isEmpty,
      ),
    );
    _savePaymentCards();
    notifyListeners();
  }

  void setDefaultCard(String id) {
    _paymentCards = _paymentCards
        .map((c) => c.copyWith(isDefault: c.id == id))
        .toList();
    _savePaymentCards();
    notifyListeners();
  }

  void removeCard(String id) {
    _paymentCards.removeWhere((c) => c.id == id);
    if (_paymentCards.isNotEmpty && !_paymentCards.any((c) => c.isDefault)) {
      _paymentCards[0] = _paymentCards[0].copyWith(isDefault: true);
    }
    _savePaymentCards();
    notifyListeners();
  }

  void togglePriceDropAlerts(bool val) {
    _priceDropAlerts = val;
    VeyraStorageService.setPriceDropAlerts(val);
    notifyListeners();
  }

  void toggleBookingUpdates(bool val) {
    _bookingUpdates = val;
    VeyraStorageService.setBookingUpdates(val);
    notifyListeners();
  }

  void toggleConciergeExclusives(bool val) {
    _conciergeExclusives = val;
    VeyraStorageService.setConciergeExclusives(val);
    notifyListeners();
  }

  void togglePushNotifications(bool val) {
    _pushNotifications = val;
    VeyraStorageService.setPushNotifications(val);
    notifyListeners();
  }

  void toggleEmailNotifications(bool val) {
    _emailNotifications = val;
    VeyraStorageService.setEmailNotifications(val);
    notifyListeners();
  }

  void toggleSmsNotifications(bool val) {
    _smsNotifications = val;
    VeyraStorageService.setSmsNotifications(val);
    notifyListeners();
  }

  void toggleQuietHours(bool val) {
    _quietHoursEnabled = val;
    VeyraStorageService.setQuietHours(val);
    notifyListeners();
  }

  void updateLanguage(String newLang) {
    _language = newLang;
    VeyraStorageService.setLanguage(newLang);
    notifyListeners();
  }

  void toggleBiometrics(bool val) {
    _biometricsEnabled = val;
    VeyraStorageService.setBiometricsEnabled(val);
    notifyListeners();
  }

  void toggleTwoFactor(bool val) {
    _twoFactorEnabled = val;
    VeyraStorageService.setTwoFactorEnabled(val);
    notifyListeners();
  }

  void revokeSession(String id) {
    _sessions.removeWhere((s) => s.id == id && !s.isCurrent);
    _saveSessions();
    notifyListeners();
  }

  void revokeOtherSessions() {
    _sessions.removeWhere((s) => !s.isCurrent);
    _saveSessions();
    notifyListeners();
  }

  /// Terminates active session and resets user security tokens.
  Future<void> signOut() async {
    _sessions.clear();
    _sessions.add(
      DeviceSession(
        id: 'session_guest_${DateTime.now().millisecondsSinceEpoch}',
        deviceName: 'Current Device',
        location: 'Local',
        lastActive: 'Just now',
        isCurrent: true,
      ),
    );
    _saveSessions();
    notifyListeners();
  }
}
