import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/stay_card.dart';
import '../../core/responsive/adaptive_scaffold.dart';
import '../../core/navigation/app_router.dart';
import '../../data/models/search_criteria.dart';
import '../../data/models/stay.dart';
import '../../features/explore/explore_controller.dart';
import '../../app.dart';
import 'widgets/stay_filters_sheet.dart';

/// Screen B — Search & Discover
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;
  const SearchScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  StaySearchController? _ctrl;
  final _queryCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl ??= AppScope.searchCtrlOf(context);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _queryCtrl.text = widget.initialQuery!;
      _ctrl?.updateQuery(widget.initialQuery!);
    }
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _ctrl?.setCategory(widget.initialCategory);
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    if (ctrl == null) return const LoadingState();
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => _SearchBody(
        ctrl: ctrl,
        queryCtrl: _queryCtrl,
      ),
    );
  }
}

class _SearchBody extends StatefulWidget {
  final StaySearchController ctrl;
  final TextEditingController queryCtrl;
  const _SearchBody({required this.ctrl, required this.queryCtrl});

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasResults = widget.ctrl.hasResults;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _SearchInputBar(ctrl: widget.ctrl, queryCtrl: widget.queryCtrl),
                _FilterRow(
                  ctrl: widget.ctrl,
                  isMapView: _isMapView,
                  onToggleMap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isMapView = !_isMapView);
                  },
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isMapView
                      ? _InteractiveMapExplorer(
                          stays: widget.ctrl.results,
                          ctrl: widget.ctrl,
                        )
                      : _SearchResultsArea(ctrl: widget.ctrl),
                ),
              ],
            ),
            // Floating View Mode Pill Button (Airbnb / luxury explorer style)
            if (hasResults)
              Positioned(
                bottom: VeyraTokens.spaceMD,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isMapView = !_isMapView);
                    },
                    child: AnimatedContainer(
                      duration: VeyraTokens.durationFast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? VeyraTokens.darkSurface
                            : VeyraTokens.deepEmerald,
                        borderRadius:
                            BorderRadius.circular(VeyraTokens.radiusFull),
                        boxShadow: VeyraTokens.shadowLG,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMapView
                                ? Icons.format_list_bulleted_rounded
                                : Icons.map_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isMapView ? 'List View' : 'Map View',
                            style: VeyraTokens.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchInputBar extends StatelessWidget {
  final StaySearchController ctrl;
  final TextEditingController queryCtrl;
  const _SearchInputBar({required this.ctrl, required this.queryCtrl});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      child: Row(
        children: [
          if (canPop) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            const SizedBox(width: VeyraTokens.spaceXS),
          ],
          Expanded(
            child: TextField(
              controller: queryCtrl,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: ctrl.updateQuery,
              decoration: InputDecoration(
                hintText: 'Search destinations, hotels…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: queryCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          queryCtrl.clear();
                          ctrl.clearAll();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          _FilterButton(onTap: () => _showFilterSheet(context, ctrl)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, StaySearchController ctrl) {
    HapticFeedback.lightImpact();
    StayFiltersBottomSheet.show(context);
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(VeyraTokens.spaceSM + 2),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        ),
        child: Icon(Icons.tune_rounded, color: scheme.onPrimary, size: 20),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final StaySearchController ctrl;
  final bool isMapView;
  final VoidCallback onToggleMap;

  const _FilterRow({
    required this.ctrl,
    required this.isMapView,
    required this.onToggleMap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip2(
            label: isMapView ? 'List' : 'Map',
            active: isMapView,
            icon: isMapView
                ? Icons.format_list_bulleted_rounded
                : Icons.map_outlined,
            onTap: onToggleMap,
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          _SortChip(ctrl: ctrl),
          const SizedBox(width: VeyraTokens.spaceSM),
          _FilterChip2(
            label: '4★+',
            active: ctrl.criteria.minRating != null &&
                ctrl.criteria.minRating! >= 4,
            onTap: () {
              HapticFeedback.lightImpact();
              final newRating =
                  ctrl.criteria.minRating == 4.0 ? null : 4.0;
              ctrl.setCriteria(ctrl.criteria.copyWith(
                minRating: newRating,
                clearMinRating: newRating == null,
              ));
            },
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          _FilterChip2(
            label: '< \$1,000',
            active: ctrl.criteria.maxPriceCents != null &&
                ctrl.criteria.maxPriceCents! <= 100000,
            onTap: () {
              HapticFeedback.lightImpact();
              final isUnder1k = ctrl.criteria.maxPriceCents == 100000;
              ctrl.setCriteria(ctrl.criteria.copyWith(
                maxPriceCents: isUnder1k ? null : 100000,
                clearMaxPrice: isUnder1k,
              ));
            },
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          if (ctrl.criteria.hasActiveFilters)
            _FilterChip2(
              label: 'Clear all',
              active: false,
              onTap: () {
                HapticFeedback.lightImpact();
                ctrl.clearAll();
              },
              icon: Icons.close_rounded,
            ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final StaySearchController ctrl;
  const _SortChip({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final labels = {
      SortBy.recommended: 'Recommended',
      SortBy.ratingDesc: 'Top Rated',
      SortBy.priceAsc: 'Price ↑',
      SortBy.priceDesc: 'Price ↓',
    };
    return GestureDetector(
      onTap: () => _showSort(context),
      child: _FilterChip2(
        label: labels[ctrl.criteria.sortBy] ?? 'Sort',
        active: ctrl.criteria.sortBy != SortBy.recommended,
        icon: Icons.sort_rounded,
        onTap: () => _showSort(context),
      ),
    );
  }

  void _showSort(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (_) => _SortSheet(ctrl: ctrl),
    );
  }
}

class _FilterChip2 extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip2({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: VeyraTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: VeyraTokens.spaceSM + 4,
          vertical: VeyraTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: active ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          border: Border.all(color: active ? scheme.primary : scheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: active ? scheme.onPrimary : scheme.onSurface),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: VeyraTokens.labelSmall.copyWith(
                color: active ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsArea extends StatelessWidget {
  final StaySearchController ctrl;
  const _SearchResultsArea({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.state == LoadState.loading && ctrl.results.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(VeyraTokens.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerSkeleton(width: 140, height: 16),
            const SizedBox(height: VeyraTokens.spaceMD),
            const GridSkeleton(itemCount: 4),
          ],
        ),
      );
    }
    if (ctrl.state == LoadState.error) {
      return ErrorState(
        message: ctrl.errorMessage ?? 'Search failed',
        onRetry: () => ctrl.setCriteria(ctrl.criteria),
      );
    }
    if (!ctrl.hasResults) {
      if (ctrl.state == LoadState.idle && ctrl.recentSearches.isNotEmpty) {
        return _RecentSearches(ctrl: ctrl);
      }
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No stays found',
        subtitle: 'Try different keywords or clear some filters.',
        actionLabel: 'Clear filters',
        onAction: () {
          HapticFeedback.lightImpact();
          ctrl.clearAll();
        },
      );
    }
    return _SearchResultsGrid(stays: ctrl.results);
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final List<Stay> stays;
  const _SearchResultsGrid({required this.stays});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = AppScope.savedCtrlOf(context);
    final themeCtrl = AppScope.themeCtrlOf(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        VeyraTokens.spaceMD,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceMD,
        VeyraTokens.space2XL + 32, // Padding so floating Map/List toggle button never overlaps cards
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stays.length} stays found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          ResponsiveStayGrid(
            cards: stays
                .map(
                  (s) {
                    final heroTag = 'search_stay_image_${s.id}';
                    return StayCard(
                      stay: s,
                      isSaved: savedCtrl?.isSaved(s.id) ?? false,
                      heroTag: heroTag,
                      showPremiumDepth:
                          themeCtrl?.premiumDepthEnabled ?? false,
                      onTap: () => navigateToStayDetails(
                        context,
                        s.id,
                        heroTag: heroTag,
                      ),
                      onFavoriteTap: () {
                        HapticFeedback.lightImpact();
                        savedCtrl?.toggleSaved(s.id);
                      },
                    );
                  },
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final StaySearchController ctrl;
  const _RecentSearches({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.recentSearches.isEmpty) {
      return const EmptyState(
        icon: Icons.travel_explore_rounded,
        title: 'Discover amazing stays',
        subtitle: 'Search by destination, hotel name, or country.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      itemCount: ctrl.recentSearches.length,
      itemBuilder: (context, i) {
        final q = ctrl.recentSearches[i];
        return ListTile(
          leading: const Icon(Icons.history_rounded),
          title: Text(q, style: Theme.of(context).textTheme.bodyLarge),
          onTap: () => ctrl.updateQuery(q),
        );
      },
    );
  }
}

class _SortSheet extends StatelessWidget {
  final StaySearchController ctrl;
  const _SortSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final options = [
      (SortBy.recommended, 'Recommended', Icons.star_outline_rounded),
      (SortBy.ratingDesc, 'Top Rated', Icons.star_rounded),
      (SortBy.priceAsc, 'Lowest Price', Icons.arrow_upward_rounded),
      (SortBy.priceDesc, 'Highest Price', Icons.arrow_downward_rounded),
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: Text('Sort By', style: Theme.of(context).textTheme.headlineMedium),
          ),
          ...options.map(
            (o) => ListTile(
              leading: Icon(o.$3),
              title: Text(o.$2),
              trailing: ctrl.criteria.sortBy == o.$1
                  ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ctrl.setSortBy(o.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final StaySearchController ctrl;
  const _FilterBottomSheet({required this.ctrl});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late SearchCriteria _local;

  @override
  void initState() {
    super.initState();
    _local = widget.ctrl.criteria;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(VeyraTokens.radiusXL),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        VeyraTokens.spaceMD,
        VeyraTokens.spaceSM,
        VeyraTokens.spaceMD,
        MediaQuery.of(context).viewInsets.bottom + VeyraTokens.spaceMD,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              _FilterHeader(onReset: () => setState(() => _local = SearchCriteria.empty)),
              const SizedBox(height: VeyraTokens.spaceMD),
              _GuestCountRow(
                guests: _local.guests,
                onChanged: (v) => setState(() => _local = _local.copyWith(guests: v)),
              ),
              const SizedBox(height: VeyraTokens.spaceMD),
              _PriceRange(
                local: _local,
                onChanged: (min, max) => setState(() => _local = _local.copyWith(
                  minPriceCents: (min * 100).round(),
                  maxPriceCents: (max * 100).round(),
                )),
              ),
              const SizedBox(height: VeyraTokens.spaceLG),
              AppButton(
                label: 'Apply Filters',
                onTap: () {
                  widget.ctrl.setCriteria(_local);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: VeyraTokens.spaceSM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
        ),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final VoidCallback onReset;
  const _FilterHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Filters', style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
        TextButton(onPressed: onReset, child: const Text('Reset')),
      ],
    );
  }
}

class _GuestCountRow extends StatelessWidget {
  final int guests;
  final ValueChanged<int> onChanged;
  const _GuestCountRow({required this.guests, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people_rounded, size: 20),
        const SizedBox(width: VeyraTokens.spaceSM),
        Text('Guests', style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        _CounterButton(
          icon: Icons.remove_rounded,
          onTap: guests > 1 ? () => onChanged(guests - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceSM),
          child: Text('$guests', style: Theme.of(context).textTheme.headlineMedium),
        ),
        _CounterButton(
          icon: Icons.add_rounded,
          onTap: guests < 20 ? () => onChanged(guests + 1) : null,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: onTap != null ? scheme.primary : scheme.outline),
      ),
    );
  }
}

class _PriceRange extends StatelessWidget {
  final SearchCriteria local;
  final void Function(double min, double max) onChanged;
  const _PriceRange({required this.local, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final minVal = (local.minPriceCents ?? 0) / 100.0;
    final maxVal = (local.maxPriceCents ?? 100000) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Range / Night', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: VeyraTokens.spaceSM),
        RangeSlider(
          values: RangeValues(minVal.clamp(0, 1000), maxVal.clamp(0, 1000)),
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels('\$${minVal.round()}', '\$${maxVal.round()}'),
          onChanged: (v) => onChanged(v.start, v.end),
        ),
      ],
    );
  }
}

// ── Interactive Map Explorer ──────────────────────────────────────────────────

class _InteractiveMapExplorer extends StatefulWidget {
  final List<Stay> stays;
  final StaySearchController ctrl;

  const _InteractiveMapExplorer({
    required this.stays,
    required this.ctrl,
  });

  @override
  State<_InteractiveMapExplorer> createState() => _InteractiveMapExplorerState();
}

class _InteractiveMapExplorerState extends State<_InteractiveMapExplorer> {
  Stay? _selectedStay;
  late final TransformationController _transformCtrl;

  @override
  void initState() {
    super.initState();
    _transformCtrl = TransformationController();
  }

  @override
  void didUpdateWidget(covariant _InteractiveMapExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedStay != null && !widget.stays.any((s) => s.id == _selectedStay!.id)) {
      _selectedStay = null;
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _resetMap() {
    HapticFeedback.lightImpact();
    _transformCtrl.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const canvasWidth = 750.0;
    const canvasHeight = 520.0;

    if (widget.stays.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.map_outlined,
          title: 'No stays to display on map',
          subtitle: 'Adjust your search filters to explore destinations.',
          actionLabel: 'Reset Filters',
          onAction: () {
            HapticFeedback.lightImpact();
            widget.ctrl.clearAll();
          },
        ),
      );
    }

    // Determine coordinate bounding box
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final s in widget.stays) {
      final lat = s.latitude ?? 20.0;
      final lng = s.longitude ?? 0.0;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    if (maxLat - minLat < 0.2) {
      minLat -= 0.5;
      maxLat += 0.5;
    }
    if (maxLng - minLng < 0.2) {
      minLng -= 0.5;
      maxLng += 0.5;
    }

    final selectedStay = _selectedStay;
    final destCounters = <String, int>{};

    return Stack(
      children: [
        // Pan & Zoom Interactive Canvas
        InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: 0.6,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(400),
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LuxuryMapPainter(
                      isDark: isDark,
                      primaryColor: scheme.primary,
                    ),
                  ),
                ),
                // Custom nightly price tag markers
                ...widget.stays.map((stay) {
                  final dest = stay.destination;
                  final destIdx = destCounters[dest] ?? 0;
                  destCounters[dest] = destIdx + 1;

                  final lat = stay.latitude ?? 20.0;
                  final lng = stay.longitude ?? 0.0;
                  final latNorm = (lat - minLat) / (maxLat - minLat);
                  final lngNorm = (lng - minLng) / (maxLng - minLng);

                  double x = 120.0 + lngNorm * (canvasWidth - 240.0);
                  double y = 60.0 + (1.0 - latNorm) * (canvasHeight - 250.0);

                  // Stagger nearby destination stays so markers never occlude each other
                  double clusterX = 0.0;
                  double clusterY = 0.0;
                  switch (destIdx % 4) {
                    case 0:
                      clusterX = -46.0;
                      clusterY = 0.0;
                      break;
                    case 1:
                      clusterX = 46.0;
                      clusterY = -24.0;
                      break;
                    case 2:
                      clusterX = 0.0;
                      clusterY = 32.0;
                      break;
                    case 3:
                      clusterX = 46.0;
                      clusterY = 24.0;
                      break;
                  }
                  x = (x + clusterX).clamp(60.0, canvasWidth - 60.0);
                  y = (y + clusterY).clamp(40.0, canvasHeight - 80.0);

                  final isSelected = selectedStay?.id == stay.id;

                  return Positioned(
                    left: x - 40,
                    top: y - 24,
                    child: _PriceTagMarker(
                      stay: stay,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedStay = stay);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Map HUD Controls (Top Right: Center Map)
        Positioned(
          top: VeyraTokens.spaceMD,
          right: VeyraTokens.spaceMD,
          child: CircleAvatar(
            backgroundColor: isDark
                ? VeyraTokens.darkCardSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: Icon(
                Icons.center_focus_strong_rounded,
                color: scheme.primary,
                size: 20,
              ),
              tooltip: 'Reset map view',
              onPressed: _resetMap,
            ),
          ),
        ),

        // Floating Stay Preview Card at the bottom of the map
        if (selectedStay != null)
          Positioned(
            bottom: 76,
            left: VeyraTokens.spaceMD,
            right: VeyraTokens.spaceMD,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _FloatingStayPreviewCard(
                  stay: selectedStay,
                  onClose: () => setState(() => _selectedStay = null),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PriceTagMarker extends StatelessWidget {
  final Stay stay;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriceTagMarker({
    required this.stay,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: VeyraTokens.durationFast,
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary
                    : (isDark ? VeyraTokens.darkCardSurface : Colors.white),
                borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? scheme.primary.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? VeyraTokens.darkBorder : Colors.black12),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.star_rounded,
                      color: VeyraTokens.antiqueGold,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Builder(
                    builder: (context) {
                      final currencyCtrl = AppScope.currencyCtrlOf(context);
                      final priceStr = currencyCtrl != null
                          ? currencyCtrl.formatCents(stay.nightlyPriceCents)
                          : stay.nightlyPriceDisplay;
                      return Text(
                        priceStr,
                        style: TextStyle(
                          color: isSelected
                              ? scheme.onPrimary
                              : (isDark ? Colors.white : VeyraTokens.obsidian),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(10, 6),
              painter: _MarkerArrowPainter(
                color: isSelected
                    ? scheme.primary
                    : (isDark ? VeyraTokens.darkCardSurface : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkerArrowPainter extends CustomPainter {
  final Color color;
  const _MarkerArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FloatingStayPreviewCard extends StatelessWidget {
  final Stay stay;
  final VoidCallback onClose;

  const _FloatingStayPreviewCard({
    required this.stay,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroTag = 'map_stay_preview_${stay.id}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        navigateToStayDetails(context, stay.id, heroTag: heroTag);
      },
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(VeyraTokens.spaceSM),
        decoration: BoxDecoration(
          color: isDark ? VeyraTokens.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
          boxShadow: VeyraTokens.shadowLG,
          border: Border.all(
            color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              child: SizedBox(
                width: 90,
                height: 88,
                child: Hero(
                  tag: heroTag,
                  createRectTween: (begin, end) =>
                      MaterialRectArcTween(begin: begin, end: end),
                  child: CachedNetworkImage(
                    imageUrl: stay.primaryImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerSkeleton(
                      borderRadius: BorderRadius.zero,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image_rounded, size: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: VeyraTokens.spaceMD),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stay.destination,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RatingBadge(rating: stay.rating),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stay.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (context) {
                                final currencyCtrl =
                                    AppScope.currencyCtrlOf(context);
                                final priceStr = currencyCtrl != null
                                    ? currencyCtrl.formatCents(stay.nightlyPriceCents)
                                    : stay.nightlyPriceDisplay;
                                return Text(
                                  priceStr,
                                  style: VeyraTokens.headlineMedium.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                );
                              },
                            ),
                            Flexible(
                              child: Text(
                                ' / night',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(VeyraTokens.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryMapPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  const _LuxuryMapPainter({
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF131D24) : const Color(0xFFF3F5F4);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Water Bodies / Coastal Bays
    final waterPaint = Paint()
      ..color = isDark ? const Color(0xFF0F171D) : const Color(0xFFDCEAF2)
      ..style = PaintingStyle.fill;

    // Coastline 1: Northern archipelago / coast
    final coast1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..cubicTo(size.width * 0.4, 120, size.width * 0.25, 180, 0, 220)
      ..close();
    canvas.drawPath(coast1, waterPaint);

    // Coastline 2: Southern bay & ocean
    final coast2 = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..cubicTo(size.width * 0.45, size.height * 0.75, size.width * 0.7, size.height * 0.8, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(coast2, waterPaint);

    // Island 1
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.35),
        width: 140,
        height: 80,
      ),
      waterPaint,
    );

    // Cartographic Grid Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 110) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 110) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Modern transit / highway arteries
    final roadPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(size.width * 0.3, size.height * 0.4, size.width * 0.6, size.height * 0.55, size.width, size.height * 0.3);
    canvas.drawPath(roadPath, roadPaint);

    final roadPath2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(size.width * 0.25, size.height * 0.4, size.width * 0.45, size.height * 0.7, size.width * 0.6, size.height);
    canvas.drawPath(roadPath2, roadPaint);

    // Topographic contours
    final contourPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.07 : 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 160, contourPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 110, contourPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.48), 140, contourPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.48), 90, contourPaint);

    // Compass Accent in top-left
    final compassPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(60, 60), 24, compassPaint);
    canvas.drawLine(const Offset(60, 42), const Offset(60, 78), compassPaint);
    canvas.drawLine(const Offset(42, 60), const Offset(78, 60), compassPaint);
  }

  @override
  bool shouldRepaint(_LuxuryMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.primaryColor != primaryColor;
}
