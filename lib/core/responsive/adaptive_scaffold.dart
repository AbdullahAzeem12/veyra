import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: scheme.primary.withValues(alpha: 0.12),
          destinations: destinations,
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
