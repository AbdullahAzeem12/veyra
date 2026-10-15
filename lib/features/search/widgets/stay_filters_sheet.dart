import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/scope/app_scope.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/search_criteria.dart';

class StayFiltersBottomSheet extends StatefulWidget {
  final bool navigateToSearchOnApply;
  const StayFiltersBottomSheet({super.key, this.navigateToSearchOnApply = false});

  static void show(BuildContext context, {bool navigateToSearchOnApply = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StayFiltersBottomSheet(
        navigateToSearchOnApply: navigateToSearchOnApply,
      ),
    );
  }

  @override
  State<StayFiltersBottomSheet> createState() => _StayFiltersBottomSheetState();
}

class _StayFiltersBottomSheetState extends State<StayFiltersBottomSheet> {
  late RangeValues _priceRange;
  late int _guests;
  late String? _selectedCategory;
  late double? _minRating;
  late Set<String> _selectedAmenities;
  late SortBy _sortBy;

  static const List<String> _categories = [
    'All',
    'Hotel',
    'Villa',
    'Resort',
    'Apartment',
  ];

  static const List<String> _amenitiesList = [
    'Private Pool',
    'Private Beach',
    'Dedicated Butler',
    'Spa & Wellness',
    'Michelin Dining',
    'Helipad',
    'Wine Cellar',
    'Infinity Pool',
    'Gym',
    'High-Speed Wi-Fi',
  ];

  @override
  void initState() {
    super.initState();
    final searchCtrl = AppScope.searchCtrlOf(context);
    final criteria = searchCtrl?.criteria ?? SearchCriteria.empty;

    final minPrice = (criteria.minPriceCents != null ? criteria.minPriceCents! / 100.0 : 100.0).clamp(100.0, 3000.0);
    final maxPrice = (criteria.maxPriceCents != null ? criteria.maxPriceCents! / 100.0 : 2500.0).clamp(minPrice, 3000.0);
    _priceRange = RangeValues(minPrice, maxPrice);

    _guests = criteria.guests;
    _selectedCategory = criteria.category;
    _minRating = criteria.minRating;
    _selectedAmenities = Set.from(criteria.amenities);
    _sortBy = criteria.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final currencyCtrl = AppScope.currencyCtrlOf(context);
    final searchCtrl = AppScope.searchCtrlOf(context);

    final minPriceDisplay = currencyCtrl != null
        ? currencyCtrl.formatCents((_priceRange.start * 100).round())
        : '\$${_priceRange.start.round()}';
    final maxPriceDisplay = currencyCtrl != null
        ? currencyCtrl.formatCents((_priceRange.end * 100).round())
        : '\$${_priceRange.end.round()}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text('Filters & Preferences', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _priceRange = const RangeValues(100, 2500);
                      _guests = 1;
                      _selectedCategory = null;
                      _minRating = null;
                      _selectedAmenities.clear();
                      _sortBy = SortBy.recommended;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              children: [
                // Price Range
                Text('Price per Night', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('$minPriceDisplay – $maxPriceDisplay',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                RangeSlider(
                  values: _priceRange,
                  min: 100,
                  max: 3000,
                  divisions: 29,
                  activeColor: scheme.primary,
                  onChanged: (values) {
                    setState(() => _priceRange = values);
                  },
                ),

                const SizedBox(height: VeyraTokens.spaceMD),
                Text('Property Category', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: VeyraTokens.spaceSM),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isAll = cat == 'All';
                    final isSelected = isAll
                        ? (_selectedCategory == null || _selectedCategory!.isEmpty)
                        : _selectedCategory == cat;
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedCategory = isAll ? null : (selected ? cat : null);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: VeyraTokens.spaceLG),
                // Guest Count
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guests', style: Theme.of(context).textTheme.titleSmall),
                        Text('Number of adult travelers', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      onPressed: _guests > 1
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _guests--);
                            }
                          : null,
                    ),
                    Text('$_guests', style: Theme.of(context).textTheme.headlineMedium),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: _guests < 10
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _guests++);
                            }
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: VeyraTokens.spaceLG),
                // Star Rating
                Text('Minimum Guest Rating', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: VeyraTokens.spaceSM),
                Row(
                  children: [null, 4.0, 4.5, 4.8].map((r) {
                    final isSelected = _minRating == r;
                    final label = r == null ? 'Any Rating' : '★ ${r.toStringAsFixed(1)}+';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (sel) {
                          HapticFeedback.lightImpact();
                          setState(() => _minRating = sel ? r : null);
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: VeyraTokens.spaceLG),
                // Luxury Amenities
                Text('Luxury Amenities & Features', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: VeyraTokens.spaceSM),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _amenitiesList.map((a) {
                    final isSelected = _selectedAmenities.contains(a);
                    return FilterChip(
                      label: Text(a),
                      selected: isSelected,
                      onSelected: (sel) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (sel) {
                            _selectedAmenities.add(a);
                          } else {
                            _selectedAmenities.remove(a);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: VeyraTokens.spaceLG),
                // Sort by
                Text('Sort Results By', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: VeyraTokens.spaceSM),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Recommended'),
                      selected: _sortBy == SortBy.recommended,
                      onSelected: (_) => setState(() => _sortBy = SortBy.recommended),
                    ),
                    ChoiceChip(
                      label: const Text('Highest Rated'),
                      selected: _sortBy == SortBy.ratingDesc,
                      onSelected: (_) => setState(() => _sortBy = SortBy.ratingDesc),
                    ),
                    ChoiceChip(
                      label: const Text('Price: Low to High'),
                      selected: _sortBy == SortBy.priceAsc,
                      onSelected: (_) => setState(() => _sortBy = SortBy.priceAsc),
                    ),
                    ChoiceChip(
                      label: const Text('Price: High to Low'),
                      selected: _sortBy == SortBy.priceDesc,
                      onSelected: (_) => setState(() => _sortBy = SortBy.priceDesc),
                    ),
                  ],
                ),
                const SizedBox(height: VeyraTokens.space2XL),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                final currentCriteria = searchCtrl?.criteria ?? SearchCriteria.empty;
                final newCriteria = currentCriteria.copyWith(
                  minPriceCents: (_priceRange.start * 100).round(),
                  maxPriceCents: (_priceRange.end * 100).round(),
                  guests: _guests,
                  category: _selectedCategory,
                  minRating: _minRating,
                  amenities: _selectedAmenities,
                  sortBy: _sortBy,
                  clearCategory: _selectedCategory == null,
                  clearMinRating: _minRating == null,
                );
                searchCtrl?.setCriteria(newCriteria);
                Navigator.of(context).pop();

                if (widget.navigateToSearchOnApply) {
                  navigateToSearch(context);
                }
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
