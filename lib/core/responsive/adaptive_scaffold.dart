import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

/// Responsive breakpoint helpers.
class Breakpoints {
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < VeyraTokens.compactBreakpoint;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= VeyraTokens.compactBreakpoint &&
        w < VeyraTokens.mediumBreakpoint;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= VeyraTokens.mediumBreakpoint;
}

/// Adaptive scaffold: bottom nav on compact, rail on wider screens.
class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = Breakpoints.isCompact(context);

    if (isCompact) {
      return Scaffold(
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: _VeyraBottomNav(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onTap: onDestinationSelected,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _VeyraNavRail(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onTap: onDestinationSelected,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _VeyraBottomNav extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _VeyraBottomNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VeyraTokens.spaceMD,
        0,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceSM,
      ),
      child: SafeArea(
        top: false,
        child: VeyraGlassSurface(
          preset: VeyraGlassPreset.navigation,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
          padding: const EdgeInsets.symmetric(
            horizontal: VeyraTokens.spaceXS,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (i) {
              final d = destinations[i];
              final isSelected = i == selectedIndex;
              return Expanded(
                child: _NavTabItem(
                  destination: d,
                  isSelected: isSelected,
                  isDark: isDark,
                  primaryColor: scheme.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(i);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final NavigationDestination destination;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.destination,
    required this.isSelected,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = primaryColor;
    final inactiveColor = isDark
        ? VeyraTokens.darkSubtext
        : VeyraTokens.lightSubtext;

    IconData iconData = Icons.circle;
    if (destination.icon is Icon) {
      iconData = (destination.icon as Icon).icon ?? Icons.circle;
    }
    if (isSelected && destination.selectedIcon is Icon) {
      iconData = (destination.selectedIcon as Icon).icon ?? iconData;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.20 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(
                iconData,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: VeyraTokens.labelSmall.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: isSelected ? 16 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: isSelected ? VeyraTokens.antiqueGold : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VeyraNavRail extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _VeyraNavRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
      child: SafeArea(
        child: NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          indicatorColor: scheme.primary.withValues(alpha: 0.12),
          useIndicator: true,
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: VeyraTokens.spaceLG),
            child: Text(
              'V',
              style: VeyraTokens.displaySmall.copyWith(
                color: scheme.primary,
                fontFamily: VeyraTokens.fontDisplay,
              ),
            ),
          ),
          destinations: destinations
              .map(
                (d) => NavigationRailDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: Text(d.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Responsive grid that auto-calculates column count from available width.
class ResponsiveStayGrid extends StatelessWidget {
  final List<Widget> cards;
  final EdgeInsetsGeometry? padding;

  const ResponsiveStayGrid({
    super.key,
    required this.cards,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
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
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: VeyraTokens.spaceMD,
            mainAxisSpacing: VeyraTokens.spaceMD,
            childAspectRatio: columns == 1 ? 0.92 : 0.76,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }
}
