import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/stay_card.dart';
import '../../core/widgets/fade_pop_item.dart';
import '../../core/localization/app_translations.dart';
import '../../data/models/stay.dart';
import '../../data/demo/demo_data.dart';
import '../../core/navigation/app_router.dart';
import '../../app.dart';
import 'explore_controller.dart';
import '../search/widgets/stay_filters_sheet.dart';

export 'explore_controller.dart' show ExploreController, LoadState;

/// Screen A — Explore / Home
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ExploreController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ctrl == null) {
      _ctrl = AppScope.exploreCtrlOf(context);
      _ctrl?.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ctrl = _ctrl;
    if (ctrl == null) return const LoadingState();
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        if (ctrl.state == LoadState.loading && ctrl.featured.isEmpty) {
          return const LoadingState();
        }
        if (ctrl.state == LoadState.error && ctrl.featured.isEmpty) {
          return ErrorState(
            message: ctrl.errorMessage ?? 'Failed to load stays.',
            onRetry: ctrl.refresh,
          );
        }
        return _ExploreBody(ctrl: ctrl);
      },
    );
  }
}

class _ExploreBody extends StatelessWidget {
  final ExploreController ctrl;
  const _ExploreBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _ExploreHeader(ctrl: ctrl),
          _CategorySection(ctrl: ctrl),
          const _CuratedDestinationsSection(),
          _FeaturedSection(stays: ctrl.featured, ctrl: ctrl),
          _TrendingSanctuariesSection(stays: ctrl.trendingSanctuaries, ctrl: ctrl),
          _ExclusiveEstatesSection(stays: ctrl.exclusiveEstates, ctrl: ctrl),
          _RecommendedHeader(ctrl: ctrl),
          _RecommendedSliverGrid(stays: ctrl.filteredRecommended, ctrl: ctrl),
          const SliverToBoxAdapter(
            child: SizedBox(height: VeyraTokens.space2XL),
          ),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  final ExploreController ctrl;
  const _ExploreHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(VeyraTokens.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VeyraTokens.spaceMD,
              VeyraTokens.spaceMD,
              VeyraTokens.spaceMD,
              VeyraTokens.spaceLG,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderTopRow(ctrl: ctrl),
                const SizedBox(height: VeyraTokens.spaceMD),
                _GreetingText(),
                const SizedBox(height: VeyraTokens.spaceMD),
                _SearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTopRow extends StatelessWidget {
  final ExploreController ctrl;
  const _HeaderTopRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    final avatarUrl = profileCtrl?.avatarUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

    return Row(
      children: [
        Text(
          'Veyra',
          style: VeyraTokens.displaySmall.copyWith(
            color: Colors.white,
            fontFamily: VeyraTokens.fontDisplay,
            shadows: VeyraTokens.headingShadows(true),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            AppShell.switchTab(context, 4);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [VeyraTokens.antiqueGold, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundImage: avatarImageProvider(avatarUrl),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    final firstName = profileCtrl?.name.split(' ').first ?? 'Alexander';
    final greeting = '${AppTranslations.tr(context, 'welcome_back')}, $firstName';
    final discover = AppTranslations.tr(context, 'discover_next_stay');
    final nextStay = AppTranslations.tr(context, 'next_stay_accent');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: VeyraTokens.labelLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          discover,
          style: VeyraTokens.displayMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontFamily: VeyraTokens.fontDisplay,
            shadows: VeyraTokens.headingShadows(true),
          ),
        ),
        Text(
          nextStay,
          style: VeyraTokens.displayMedium.copyWith(
            color: Colors.white,
            fontFamily: VeyraTokens.fontDisplay,
            shadows: VeyraTokens.headingShadows(true),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VeyraGlassSurface(
      preset: VeyraGlassPreset.floating,
      borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                navigateToSearch(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VeyraTokens.spaceMD,
                  vertical: VeyraTokens.spaceMD - 2,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: VeyraTokens.antiqueGold, size: 22),
                    const SizedBox(width: VeyraTokens.spaceSM),
                    Expanded(
                      child: Text(
                        AppTranslations.tr(context, 'search_hint'),
                        style: VeyraTokens.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          VeyraPressable(
            onTap: () {
              StayFiltersBottomSheet.show(context, navigateToSearchOnApply: true);
            },
            borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
            child: Padding(
              padding: const EdgeInsets.only(right: VeyraTokens.spaceSM),
              child: Container(
                padding: const EdgeInsets.all(VeyraTokens.spaceXS + 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ExploreController ctrl;
  const _CategorySection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(
          top: VeyraTokens.spaceSM,
          bottom: VeyraTokens.spaceXS,
        ),
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: ctrl.categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: VeyraTokens.spaceSM),
          itemBuilder: (context, i) {
            final cat = ctrl.categories[i];
            final selected = ctrl.selectedCategory == cat;
            final count = _getCategoryCount(cat, ctrl.recommended);
            return FadePopItem(
              index: i,
              child: _CategoryChip(
                label: cat,
                selected: selected,
                count: count,
                icon: _getCategoryIcon(cat),
                onTap: () {
                  HapticFeedback.lightImpact();
                  ctrl.setCategory(cat);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  static int _getCategoryCount(String category, List<Stay> stays) {
    if (category == 'All') return stays.length;
    final norm = category
        .toLowerCase()
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .trim();
    return stays
        .where((s) =>
            s.category
                .toLowerCase()
                .replaceAll('â', 'a')
                .replaceAll('é', 'e')
                .trim() ==
            norm)
        .length;
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.auto_awesome_rounded;
      case 'villa':
        return Icons.holiday_village_rounded;
      case 'château':
      case 'chateau':
        return Icons.castle_rounded;
      case 'island':
        return Icons.beach_access_rounded;
      case 'overwater':
        return Icons.water_rounded;
      case 'chalet':
        return Icons.cabin_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.travel_explore_rounded;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return VeyraPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.88),
                  ],
                )
              : null,
          color: selected
              ? null
              : (isDark
                  ? VeyraTokens.darkCardSurface.withValues(alpha: 0.85)
                  : Colors.white),
          border: Border.all(
            color: selected
                ? VeyraTokens.antiqueGold.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : VeyraTokens.lightBorder),
            width: selected ? 1.4 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.38),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : (isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : VeyraTokens.shadowSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? Colors.white
                  : (isDark ? VeyraTokens.antiqueGold : scheme.primary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: VeyraTokens.labelMedium.copyWith(
                color: selected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : scheme.onSurface),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12.5,
                letterSpacing: 0.2,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : scheme.primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  '$count',
                  style: VeyraTokens.labelSmall.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : scheme.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CuratedDestinationsSection extends StatelessWidget {
  const _CuratedDestinationsSection();

  @override
  Widget build(BuildContext context) {
    final destinations = DemoData.destinations;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: VeyraTokens.spaceMD),
          _SectionHeader(
            title: 'Curated Destinations',
            onSeeAll: () => navigateToSearch(context),
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
              scrollDirection: Axis.horizontal,
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(width: VeyraTokens.spaceSM + 4),
              itemBuilder: (context, i) {
                final dest = destinations[i];
                final name = dest['name'] as String? ?? '';
                final country = dest['country'] as String? ?? '';
                final imageUrl = dest['imageUrl'] as String? ?? '';
                final stayCount = dest['stayCount'] as int? ?? 12;

                return FadePopItem(
                  index: i,
                  child: VeyraPressable(
                    onTap: () {
                      final searchCtrl = AppScope.searchCtrlOf(context);
                      searchCtrl?.updateQuery(name);
                      AppShell.switchTab(context, 1);
                    },
                    borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
                    child: Container(
                      width: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
                        boxShadow: VeyraTokens.shadowSM,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const ShimmerSkeleton(
                              borderRadius: BorderRadius.zero,
                            ),
                            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade400),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                  stops: const [0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: VeyraTokens.spaceSM,
                            right: VeyraTokens.spaceSM,
                            bottom: VeyraTokens.spaceSM,
                            child: VeyraGlassSurface(
                              preset: VeyraGlassPreset.subtle,
                              borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                              padding: const EdgeInsets.symmetric(
                                horizontal: VeyraTokens.spaceSM,
                                vertical: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: VeyraTokens.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '$country · $stayCount stays',
                                    style: VeyraTokens.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 9.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  final List<Stay> stays;
  final ExploreController ctrl;

  const _FeaturedSection({required this.stays, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: VeyraTokens.spaceMD),
          _SectionHeader(
            title: AppTranslations.tr(context, 'featured_stays'),
            onSeeAll: () => navigateToSearch(context),
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          SizedBox(
            height: 252,
            child: ListView.builder(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(
                horizontal: VeyraTokens.spaceMD,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: stays.length,
              itemBuilder: (context, i) {
                final stay = stays[i];
                return FadePopItem(
                  index: i,
                  child: _FeaturedCardWrapper(stay: stay, ctrl: ctrl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCardWrapper extends StatelessWidget {
  final Stay stay;
  final ExploreController ctrl;
  const _FeaturedCardWrapper({required this.stay, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = AppScope.savedCtrlOf(context);
    final saved = savedCtrl?.isSaved(stay.id) ?? false;
    final heroTag = 'featured_stay_image_${stay.id}';
    return FeaturedStayCard(
      stay: stay,
      isSaved: saved,
      heroTag: heroTag,
      onTap: () => navigateToStayDetails(context, stay.id, heroTag: heroTag),
      onFavoriteTap: () {
        HapticFeedback.lightImpact();
        savedCtrl?.toggleSaved(stay.id);
      },
    );
  }
}

class _TrendingSanctuariesSection extends StatelessWidget {
  final List<Stay> stays;
  final ExploreController ctrl;

  const _TrendingSanctuariesSection({required this.stays, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: VeyraTokens.spaceLG),
          _SectionHeader(
            title: 'World-Class Sanctuaries',
            subtitle: 'Iconic escapes rated 4.9+ stars',
            onSeeAll: () {
              final searchCtrl = AppScope.searchCtrlOf(context);
              searchCtrl?.updateMinRating(4.8);
              AppShell.switchTab(context, 1);
            },
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          SizedBox(
            height: 236,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: stays.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: VeyraTokens.spaceSM + 4),
              itemBuilder: (context, i) {
                final stay = stays[i];
                final savedCtrl = AppScope.savedCtrlOf(context);
                final saved = savedCtrl?.isSaved(stay.id) ?? false;
                final heroTag = 'sanctuary_stay_${stay.id}';

                return FadePopItem(
                  index: i,
                  child: LuxurySanctuaryCard(
                    stay: stay,
                    isSaved: saved,
                    heroTag: heroTag,
                    badgeText: '★ ${stay.rating}',
                    onTap: () => navigateToStayDetails(context, stay.id,
                        heroTag: heroTag),
                    onFavoriteTap: () {
                      HapticFeedback.lightImpact();
                      savedCtrl?.toggleSaved(stay.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExclusiveEstatesSection extends StatelessWidget {
  final List<Stay> stays;
  final ExploreController ctrl;

  const _ExclusiveEstatesSection({required this.stays, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: VeyraTokens.spaceLG),
          _SectionHeader(
            title: 'Estates, Islands & Chalets',
            subtitle: 'Ultra-secluded retreats with bespoke service',
            onSeeAll: () {
              final searchCtrl = AppScope.searchCtrlOf(context);
              searchCtrl?.setCategory('Château');
              AppShell.switchTab(context, 1);
            },
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          SizedBox(
            height: 236,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: stays.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: VeyraTokens.spaceSM + 4),
              itemBuilder: (context, i) {
                final stay = stays[i];
                final savedCtrl = AppScope.savedCtrlOf(context);
                final saved = savedCtrl?.isSaved(stay.id) ?? false;
                final heroTag = 'exclusive_stay_${stay.id}';

                return FadePopItem(
                  index: i,
                  child: LuxurySanctuaryCard(
                    stay: stay,
                    isSaved: saved,
                    heroTag: heroTag,
                    badgeText: stay.category,
                    onTap: () => navigateToStayDetails(context, stay.id,
                        heroTag: heroTag),
                    onFavoriteTap: () {
                      HapticFeedback.lightImpact();
                      savedCtrl?.toggleSaved(stay.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedHeader extends StatelessWidget {
  final ExploreController ctrl;
  const _RecommendedHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final count = ctrl.filteredRecommended.length;
    final cat = ctrl.selectedCategory;
    final title = cat == 'All'
        ? AppTranslations.tr(context, 'recommended_for_you')
        : '$cat Sanctuaries';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: VeyraTokens.spaceLG,
          bottom: VeyraTokens.spaceSM,
        ),
        child: _SectionHeader(
          title: title,
          subtitle: '$count properties available for booking',
          onSeeAll: () {
            final searchCtrl = AppScope.searchCtrlOf(context);
            if (cat != 'All') {
              searchCtrl?.setCategory(cat);
            }
            AppShell.switchTab(context, 1);
          },
        ),
      ),
    );
  }
}

class _RecommendedSliverGrid extends StatelessWidget {
  final List<Stay> stays;
  final ExploreController ctrl;

  const _RecommendedSliverGrid({required this.stays, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VeyraTokens.spaceMD,
            vertical: VeyraTokens.spaceXL,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.holiday_village_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: VeyraTokens.spaceSM),
                Text(
                  'No ${ctrl.selectedCategory} stays found',
                  style: VeyraTokens.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Try choosing another category or explore all stays.',
                  style: VeyraTokens.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          int columns;
          if (width < 500) {
            columns = 1;
          } else if (width < 800) {
            columns = 2;
          } else if (width < 1200) {
            columns = 3;
          } else {
            columns = 4;
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: VeyraTokens.spaceMD,
              mainAxisSpacing: VeyraTokens.spaceMD,
              childAspectRatio: columns == 1 ? 0.92 : 0.76,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stay = stays[index];
                return ScrollFadePopItem(
                  child: _RecommendedCardWrapper(stay: stay),
                );
              },
              childCount: stays.length,
            ),
          );
        },
      ),
    );
  }
}

class _RecommendedCardWrapper extends StatelessWidget {
  final Stay stay;
  const _RecommendedCardWrapper({required this.stay});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = AppScope.savedCtrlOf(context);
    final saved = savedCtrl?.isSaved(stay.id) ?? false;
    final themeCtrl = AppScope.themeCtrlOf(context);
    final heroTag = 'stay_image_${stay.id}';
    return StayCard(
      stay: stay,
      isSaved: saved,
      heroTag: heroTag,
      showPremiumDepth: themeCtrl?.premiumDepthEnabled ?? false,
      onTap: () => navigateToStayDetails(context, stay.id, heroTag: heroTag),
      onFavoriteTap: () {
        HapticFeedback.lightImpact();
        savedCtrl?.toggleSaved(stay.id);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        shadows: VeyraTokens.headingShadows(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: VeyraTokens.bodySmall.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          if (onSeeAll != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                onTap: onSeeAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VeyraTokens.spaceSM,
                    vertical: VeyraTokens.spaceXS,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppTranslations.tr(context, 'view_all'),
                        style: VeyraTokens.labelLarge.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
