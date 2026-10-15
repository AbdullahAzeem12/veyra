import 'package:flutter/material.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/stay_details/stay_details_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/trips/trips_screen.dart';
import '../../features/profile/profile_screen.dart';

/// Named route constants.
abstract class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const stayDetails = '/stay-details';
  static const saved = '/saved';
  static const trips = '/trips';
  static const profile = '/profile';
}

/// Page-specific slide+fade transition.
PageRouteBuilder<T> _slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Navigate to Stay Details with smooth slide transition.
void navigateToStayDetails(BuildContext context, String stayId, {String? heroTag}) {
  Navigator.of(context).push(
    _slideRoute(StayDetailsScreen(stayId: stayId, heroTag: heroTag)),
  );
}

/// Navigate to Search screen.
void navigateToSearch(
  BuildContext context, {
  String? initialQuery,
  String? initialCategory,
}) {
  Navigator.of(context).push(
    _slideRoute(
      SearchScreen(
        initialQuery: initialQuery,
        initialCategory: initialCategory,
      ),
    ),
  );
}

/// App router for named routes.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return _slideRoute(const ExploreScreen());
    case AppRoutes.search:
      final query = settings.arguments as String?;
      return _slideRoute(SearchScreen(initialQuery: query));
    case AppRoutes.stayDetails:
      final stayId = settings.arguments as String? ?? '';
      return _slideRoute(StayDetailsScreen(stayId: stayId));
    case AppRoutes.saved:
      return _slideRoute(const SavedScreen());
    case AppRoutes.trips:
      return _slideRoute(const TripsScreen());
    case AppRoutes.profile:
      return _slideRoute(const ProfileScreen());
    default:
      return _slideRoute(const ExploreScreen());
  }
}
