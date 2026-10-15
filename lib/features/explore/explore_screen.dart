import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/stay_card.dart';
import '../../core/widgets/fade_pop_item.dart';
import '../../core/localization/app_translations.dart';
import '../../core/responsive/adaptive_scaffold.dart';
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
        slivers: [
          _ExploreHeader(ctrl: ctrl),
          _CategorySection(ctrl: ctrl),
          const _CuratedDestinationsSection(),
          _FeaturedSection(stays: ctrl.featured, ctrl: ctrl),
          _RecommendedSection(stays: ctrl.filteredRecommended, ctrl: ctrl),
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
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: VeyraTokens.spaceMD,
            vertical: VeyraTokens.spaceSM,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: ctrl.categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: VeyraTokens.spaceSM),
          itemBuilder: (context, i) {
            final cat = ctrl.categories[i];
            final selected = ctrl.selectedCategory == cat;
            return FadePopItem(
              index: i,
              child: _CategoryChip(
                label: cat,
                selected: selected,
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
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
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
        duration: VeyraTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: VeyraTokens.spaceMD,
          vertical: VeyraTokens.spaceXS + 1,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : (isDark ? VeyraTokens.darkCardSurface : Colors.white),
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          border: Border.all(
            color: selected
                ? scheme.primary
                : (isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : VeyraTokens.shadowSM,
        ),
        child: Text(
          label,
          style: VeyraTokens.labelSmall.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
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

class _RecommendedSection extends StatelessWidget {
  final List<Stay> stays;
  final ExploreController ctrl;

  const _RecommendedSection({required this.stays, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: VeyraTokens.spaceLG),
          _SectionHeader(
            title: AppTranslations.tr(context, 'recommended_for_you'),
            onSeeAll: () => navigateToSearch(context),
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
            child: ResponsiveStayGrid(
              cards: stays
                  .asMap()
                  .entries
                  .map((e) => FadePopItem(
                        index: e.key,
                        child: _RecommendedCardWrapper(stay: e.value),
                      ))
                  .toList(),
            ),
          ),
        ],
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
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    shadows: VeyraTokens.headingShadows(isDark),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
