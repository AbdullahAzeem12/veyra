import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/design_tokens.dart';
import 'core/responsive/adaptive_scaffold.dart';
import 'core/navigation/app_router.dart';
import 'core/localization/app_translations.dart';
import 'data/repositories/demo_repository.dart';
import 'features/explore/explore_controller.dart';
import 'features/saved/saved_controller.dart';
import 'features/trips/booking_controller.dart';
import 'features/explore/explore_screen.dart';
import 'features/search/search_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/trips/trips_screen.dart';
import 'features/profile/profile_screen.dart';
import 'core/scope/app_scope.dart';

export 'core/scope/app_scope.dart';

/// Root widget — owns all top-level controllers.
class VeyraApp extends StatefulWidget {
  const VeyraApp({super.key});

  @override
  State<VeyraApp> createState() => _VeyraAppState();
}

class _VeyraAppState extends State<VeyraApp> {
  late final ThemeController _themeCtrl;

  // Repositories (demo mode)
  late final DemoStayRepository _stayRepo;
  late final DemoSavedRepository _savedRepo;
  late final DemoBookingRepository _bookingRepo;

  // Feature controllers
  late final ExploreController _exploreCtrl;
  late final StaySearchController _searchCtrl;
  late final SavedController _savedCtrl;
  late final BookingController _bookingCtrl;
  late final CurrencyController _currencyCtrl;
  late final UserProfileController _profileCtrl;

  @override
  void initState() {
    super.initState();
    _themeCtrl = ThemeController();
    _themeCtrl.load();

    _stayRepo = DemoStayRepository();
    _savedRepo = DemoSavedRepository();
    _bookingRepo = DemoBookingRepository();

    _exploreCtrl = ExploreController(_stayRepo);
    _searchCtrl = StaySearchController(_stayRepo);
    _savedCtrl = SavedController(_savedRepo, 'guest');
    _bookingCtrl = BookingController(_bookingRepo);
    _currencyCtrl = CurrencyController();
    _profileCtrl = UserProfileController();

    _exploreCtrl.load();
    _searchCtrl.load();
    _savedCtrl.load();
    _bookingCtrl.loadBookings('guest');
  }

  @override
  void dispose() {
    _exploreCtrl.dispose();
    _searchCtrl.dispose();
    _savedCtrl.dispose();
    _bookingCtrl.dispose();
    _currencyCtrl.dispose();
    _profileCtrl.dispose();
    _stayRepo.dispose();
    _savedRepo.dispose();
    _bookingRepo.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeCtrl, _currencyCtrl, _profileCtrl]),
      builder: (context, _) => AppScope(
        exploreCtrl: _exploreCtrl,
        searchCtrl: _searchCtrl,
        savedCtrl: _savedCtrl,
        bookingCtrl: _bookingCtrl,
        themeCtrl: _themeCtrl,
        currencyCtrl: _currencyCtrl,
        profileCtrl: _profileCtrl,
        child: MaterialApp(
          title: 'Veyra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeCtrl.themeMode,
          onGenerateRoute: onGenerateRoute,
          builder: (context, child) {
            final isRtl = AppTranslations.isRtl(_profileCtrl.language);
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AppShell(),
        ),
      ),
    );
  }
}

/// AppShell manages the responsive shell navigation and active bottom bar/rail index.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    state?.setTab(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void setTab(int index) {
    if (mounted && index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  List<NavigationDestination> _buildDestinations(BuildContext context) => [
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore_rounded),
          label: AppTranslations.tr(context, 'nav_explore'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search_rounded),
          label: AppTranslations.tr(context, 'nav_search'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_outline_rounded),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: AppTranslations.tr(context, 'nav_saved'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.luggage_outlined),
          selectedIcon: const Icon(Icons.luggage_rounded),
          label: AppTranslations.tr(context, 'nav_trips'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: AppTranslations.tr(context, 'nav_profile'),
        ),
      ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ExploreScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const SavedScreen();
      case 3:
        return const TripsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const ExploreScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: setTab,
      destinations: _buildDestinations(context),
      body: AnimatedSwitcher(
        duration: VeyraTokens.durationNormal,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _buildBody(),
        ),
      ),
    );
  }
}
