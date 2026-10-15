import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/stay_card.dart';
import '../../core/responsive/adaptive_scaffold.dart';
import '../../core/navigation/app_router.dart';
import '../../data/models/stay.dart';
import '../../data/demo/demo_data.dart';
import '../../features/saved/saved_controller.dart';
import '../../app.dart';

/// Screen D — Saved Stays
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = AppScope.savedCtrlOf(context);
    if (savedCtrl == null) return const LoadingState();
    return ListenableBuilder(
      listenable: savedCtrl,
      builder: (context, _) {
        if (savedCtrl.isLoading) return const LoadingState();
        final ids = savedCtrl.savedIds;
        final stays = DemoData.allStays.where((s) => ids.contains(s.id)).toList();
        return _SavedBody(stays: stays, savedCtrl: savedCtrl);
      },
    );
  }
}

class _SavedBody extends StatelessWidget {
  final List<Stay> stays;
  final SavedController savedCtrl;

  const _SavedBody({required this.stays, required this.savedCtrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: stays.isEmpty
            ? _SavedEmpty()
            : _SavedContent(stays: stays, savedCtrl: savedCtrl),
      ),
    );
  }
}

class _SavedContent extends StatefulWidget {
  final List<Stay> stays;
  final SavedController savedCtrl;

  const _SavedContent({required this.stays, required this.savedCtrl});

  @override
  State<_SavedContent> createState() => _SavedContentState();
}

class _SavedContentState extends State<_SavedContent> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? widget.stays
        : widget.stays
            .where((s) =>
                s.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

    return CustomScrollView(
      slivers: [
        _SavedHeader(
          count: widget.stays.length,
          selectedCategory: _selectedCategory,
          onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
          savedStays: widget.stays,
        ),
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(VeyraTokens.space2XL),
              child: Center(
                child: Text(
                  'No saved stays in "$_selectedCategory"',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          _SavedGrid(stays: filtered, savedCtrl: widget.savedCtrl),
        const SliverToBoxAdapter(child: SizedBox(height: VeyraTokens.space2XL)),
      ],
    );
  }
}

class _SavedHeader extends StatelessWidget {
  final int count;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<Stay> savedStays;

  const _SavedHeader({
    required this.count,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.savedStays,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Villa', 'Hotel', 'Resort', 'Apartment'];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VeyraTokens.spaceMD,
          VeyraTokens.spaceLG,
          VeyraTokens.spaceMD,
          VeyraTokens.spaceSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saved Stays',
                          style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: VeyraTokens.spaceXS),
                      Text(
                        '$count ${count == 1 ? 'stay' : 'stays'} in your wishlist',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Share Wishlist',
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'My Curated Veyra Luxury Wishlist:\n${savedStays.map((s) => '• ${s.title} (${s.destination})').join('\n')}',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wishlist summary copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected =
                      selectedCategory.toLowerCase() == cat.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        onCategorySelected(cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedGrid extends StatelessWidget {
  final List<Stay> stays;
  final SavedController savedCtrl;

  const _SavedGrid({required this.stays, required this.savedCtrl});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = AppScope.themeCtrlOf(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final stay = stays[i];
            return _SavedCardWrapper(
              stay: stay,
              savedCtrl: savedCtrl,
              showPremium: themeCtrl?.premiumDepthEnabled ?? false,
            );
          },
          childCount: stays.length,
        ),
        gridDelegate: _buildGridDelegate(context),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(BuildContext ctx) {
    final isCompact = Breakpoints.isCompact(ctx);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isCompact ? 1 : 2,
      crossAxisSpacing: VeyraTokens.spaceMD,
      mainAxisSpacing: VeyraTokens.spaceMD,
      childAspectRatio: isCompact ? 0.92 : 0.76,
    );
  }
}

class _SavedCardWrapper extends StatelessWidget {
  final Stay stay;
  final SavedController savedCtrl;
  final bool showPremium;

  const _SavedCardWrapper({
    required this.stay,
    required this.savedCtrl,
    required this.showPremium,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = 'saved_stay_image_${stay.id}';
    return Dismissible(
      key: Key('saved_${stay.id}'),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      onDismissed: (_) {
        savedCtrl.toggleSaved(stay.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stay.title} removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => savedCtrl.toggleSaved(stay.id),
            ),
          ),
        );
      },
      child: StayCard(
        stay: stay,
        isSaved: true,
        heroTag: heroTag,
        showPremiumDepth: showPremium,
        onTap: () => navigateToStayDetails(context, stay.id, heroTag: heroTag),
        onFavoriteTap: () {
          savedCtrl.toggleSaved(stay.id);
        },
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}

class _SavedEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_outline_rounded,
      title: 'No saved stays yet',
      subtitle: 'Tap the heart on any property to save it here.',
      actionLabel: 'Explore stays',
      onAction: () => Navigator.of(context).popUntil((r) => r.isFirst),
    );
  }
}
