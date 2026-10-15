import 'package:flutter/foundation.dart';
import '../../core/storage/veyra_storage_service.dart';

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

class RewardVoucher {
  final String id;
  final String title;
  final String code;
  final int pointsSpent;
  final DateTime redeemedAt;

  const RewardVoucher({
    required this.id,
    required this.title,
    required this.code,
    required this.pointsSpent,
    required this.redeemedAt,
  });
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
}

class UserProfileController extends ChangeNotifier {
  String _name = 'Alexander Wright';
  final String _email = 'alexander.wright@veyra.travel';
  String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
  int _points = 4250;
  final String _tier = 'Veyra Black Tier';

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
  final List<DeviceSession> _sessions = [
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
  final List<RewardVoucher> _vouchers = [];

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
  String get tier => _tier;

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

  bool redeemReward(String title, int pointsCost) {
    if (_points >= pointsCost) {
      _points -= pointsCost;
      VeyraStorageService.setPoints(_points);
      final code = 'VRA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _vouchers.insert(
        0,
        RewardVoucher(
          id: 'v_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          code: code,
          pointsSpent: pointsCost,
          redeemedAt: DateTime.now(),
        ),
      );
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

  void revokeOtherSessions() {
    _sessions.removeWhere((s) => !s.isCurrent);
    notifyListeners();
  }
}
