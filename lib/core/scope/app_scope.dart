import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import 'currency_controller.dart';
import '../../features/explore/explore_controller.dart';
import '../../features/saved/saved_controller.dart';
import '../../features/trips/booking_controller.dart';
import '../../features/profile/profile_controller.dart';

export 'currency_controller.dart';
export '../../features/profile/profile_controller.dart';

/// Scoped controller provider for Veyra.
/// Provides access to all feature controllers and the theme controller.
class AppScope extends InheritedWidget {
  final ExploreController exploreCtrl;
  final StaySearchController searchCtrl;
  final SavedController savedCtrl;
  final BookingController bookingCtrl;
  final ThemeController themeCtrl;
  final CurrencyController currencyCtrl;
  final UserProfileController profileCtrl;

  const AppScope({
    super.key,
    required this.exploreCtrl,
    required this.searchCtrl,
    required this.savedCtrl,
    required this.bookingCtrl,
    required this.themeCtrl,
    required this.currencyCtrl,
    required this.profileCtrl,
    required super.child,
  });

  static AppScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  static AppScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AppScope found in context');
    return scope!;
  }

  static ExploreController? exploreCtrlOf(BuildContext context) =>
      maybeOf(context)?.exploreCtrl;

  static StaySearchController? searchCtrlOf(BuildContext context) =>
      maybeOf(context)?.searchCtrl;

  static SavedController? savedCtrlOf(BuildContext context) =>
      maybeOf(context)?.savedCtrl;

  static BookingController? bookingCtrlOf(BuildContext context) =>
      maybeOf(context)?.bookingCtrl;

  static ThemeController? themeCtrlOf(BuildContext context) =>
      maybeOf(context)?.themeCtrl;

  static CurrencyController? currencyCtrlOf(BuildContext context) =>
      maybeOf(context)?.currencyCtrl;

  static UserProfileController? profileCtrlOf(BuildContext context) =>
      maybeOf(context)?.profileCtrl;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
