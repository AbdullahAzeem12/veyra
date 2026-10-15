import 'package:flutter/foundation.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double rateFromUSD;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.rateFromUSD,
  });
}

/// Global currency management controller for real-time price conversions.
class CurrencyController extends ChangeNotifier {
  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      flag: '🇺🇸',
      rateFromUSD: 1.0,
    ),
    CurrencyInfo(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
      rateFromUSD: 0.92,
    ),
    CurrencyInfo(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      flag: '🇬🇧',
      rateFromUSD: 0.79,
    ),
    CurrencyInfo(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      rateFromUSD: 155.0,
    ),
    CurrencyInfo(
      code: 'CAD',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      rateFromUSD: 1.36,
    ),
    CurrencyInfo(
      code: 'AUD',
      symbol: 'AU\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      rateFromUSD: 1.52,
    ),
    CurrencyInfo(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      rateFromUSD: 0.90,
    ),
    CurrencyInfo(
      code: 'AED',
      symbol: 'AED',
      name: 'UAE Dirham',
      flag: '🇦🇪',
      rateFromUSD: 3.67,
    ),
  ];

  CurrencyInfo _current = supportedCurrencies.first;

  CurrencyInfo get current => _current;
  String get code => _current.code;
  String get symbol => _current.symbol;

  void setCurrency(String code) {
    final match = supportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => _current,
    );
    if (match.code != _current.code) {
      _current = match;
      notifyListeners();
    }
  }

  /// Convert a price in USD cents to the active currency string.
  String formatCents(int centsUSD, {bool includeCode = false}) {
    final convertedAmount = (centsUSD / 100.0) * _current.rateFromUSD;
    final hasCents = _current.code != 'JPY' &&
        (convertedAmount - convertedAmount.roundToDouble()).abs() > 0.001;
    final formattedNumber = hasCents
        ? convertedAmount.toStringAsFixed(2)
        : convertedAmount.round().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );

    if (includeCode) {
      return '${_current.symbol}$formattedNumber ${_current.code}';
    }
    return '${_current.symbol}$formattedNumber';
  }
}
