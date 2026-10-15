import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local database storage service for Veyra.
/// Persists user preferences, name, avatar, language, notifications, and security settings.
class VeyraStorageService {
  static const String _kUserName = 'veyra_user_name';
  static const String _kUserAvatar = 'veyra_user_avatar';
  static const String _kLanguage = 'veyra_language';
  static const String _kPriceDropAlerts = 'veyra_price_drop_alerts';
  static const String _kBookingUpdates = 'veyra_booking_updates';
  static const String _kConciergeExclusives = 'veyra_concierge_exclusives';
  static const String _kPushNotifications = 'veyra_push_notifications';
  static const String _kEmailNotifications = 'veyra_email_notifications';
  static const String _kSmsNotifications = 'veyra_sms_notifications';
  static const String _kQuietHours = 'veyra_quiet_hours';
  static const String _kBiometricsEnabled = 'veyra_biometrics_enabled';
  static const String _kTwoFactorEnabled = 'veyra_two_factor_enabled';
  static const String _kPaymentCards = 'veyra_payment_cards';
  static const String _kPoints = 'veyra_points';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences? get prefs => _prefs;

  // Name
  static String getUserName({String fallback = 'Alexander Wright'}) {
    return _prefs?.getString(_kUserName) ?? fallback;
  }

  static Future<bool> setUserName(String name) async {
    return await _prefs?.setString(_kUserName, name) ?? false;
  }

  // Avatar URL
  static String getUserAvatar({
    String fallback =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
  }) {
    return _prefs?.getString(_kUserAvatar) ?? fallback;
  }

  static Future<bool> setUserAvatar(String url) async {
    return await _prefs?.setString(_kUserAvatar, url) ?? false;
  }

  // Language
  static String getLanguage({String fallback = 'English (US)'}) {
    return _prefs?.getString(_kLanguage) ?? fallback;
  }

  static Future<bool> setLanguage(String lang) async {
    return await _prefs?.setString(_kLanguage, lang) ?? false;
  }

  // Notifications
  static bool getPriceDropAlerts({bool fallback = true}) {
    return _prefs?.getBool(_kPriceDropAlerts) ?? fallback;
  }

  static Future<bool> setPriceDropAlerts(bool val) async {
    return await _prefs?.setBool(_kPriceDropAlerts, val) ?? false;
  }

  static bool getBookingUpdates({bool fallback = true}) {
    return _prefs?.getBool(_kBookingUpdates) ?? fallback;
  }

  static Future<bool> setBookingUpdates(bool val) async {
    return await _prefs?.setBool(_kBookingUpdates, val) ?? false;
  }

  static bool getConciergeExclusives({bool fallback = true}) {
    return _prefs?.getBool(_kConciergeExclusives) ?? fallback;
  }

  static Future<bool> setConciergeExclusives(bool val) async {
    return await _prefs?.setBool(_kConciergeExclusives, val) ?? false;
  }

  static bool getPushNotifications({bool fallback = true}) {
    return _prefs?.getBool(_kPushNotifications) ?? fallback;
  }

  static Future<bool> setPushNotifications(bool val) async {
    return await _prefs?.setBool(_kPushNotifications, val) ?? false;
  }

  static bool getEmailNotifications({bool fallback = true}) {
    return _prefs?.getBool(_kEmailNotifications) ?? fallback;
  }

  static Future<bool> setEmailNotifications(bool val) async {
    return await _prefs?.setBool(_kEmailNotifications, val) ?? false;
  }

  static bool getSmsNotifications({bool fallback = false}) {
    return _prefs?.getBool(_kSmsNotifications) ?? fallback;
  }

  static Future<bool> setSmsNotifications(bool val) async {
    return await _prefs?.setBool(_kSmsNotifications, val) ?? false;
  }

  static bool getQuietHours({bool fallback = false}) {
    return _prefs?.getBool(_kQuietHours) ?? fallback;
  }

  static Future<bool> setQuietHours(bool val) async {
    return await _prefs?.setBool(_kQuietHours, val) ?? false;
  }

  // Security
  static bool getBiometricsEnabled({bool fallback = true}) {
    return _prefs?.getBool(_kBiometricsEnabled) ?? fallback;
  }

  static Future<bool> setBiometricsEnabled(bool val) async {
    return await _prefs?.setBool(_kBiometricsEnabled, val) ?? false;
  }

  static bool getTwoFactorEnabled({bool fallback = false}) {
    return _prefs?.getBool(_kTwoFactorEnabled) ?? fallback;
  }

  static Future<bool> setTwoFactorEnabled(bool val) async {
    return await _prefs?.setBool(_kTwoFactorEnabled, val) ?? false;
  }

  // Points
  static int getPoints({int fallback = 4250}) {
    return _prefs?.getInt(_kPoints) ?? fallback;
  }

  static Future<bool> setPoints(int pts) async {
    return await _prefs?.setInt(_kPoints, pts) ?? false;
  }

  // Payment Cards
  static List<Map<String, dynamic>>? getPaymentCards() {
    final raw = _prefs?.getString(_kPaymentCards);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setPaymentCards(List<Map<String, dynamic>> cards) async {
    final raw = jsonEncode(cards);
    return await _prefs?.setString(_kPaymentCards, raw) ?? false;
  }
}
