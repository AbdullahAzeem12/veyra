import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/design_tokens.dart';

/// Glass-morphism panel using BackdropFilter + ClipRRect.
/// Use sparingly — blur is GPU-intensive in scrolling lists.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 12,
    this.opacity = 0.12,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(VeyraTokens.radiusLG);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: isDark
                ? Colors.white.withValues(alpha: opacity * 0.6)
                : Colors.white.withValues(alpha: (opacity * 1.8).clamp(0.0, 1.0)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Veyra primary button with loading and disabled states.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary;
    final fg = foregroundColor ?? scheme.onPrimary;

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: VeyraTokens.spaceSM),
              ],
              Flexible(
                child: Text(
                  label,
                  style: VeyraTokens.labelLarge.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    final button = AnimatedContainer(
      duration: VeyraTokens.durationFast,
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.6),
        ),
        child: content,
      ),
    );

    return button;
  }
}

/// Animated favourite/heart button.
class FavoriteButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onTap;
  final double size;
  final bool showBackground;

  const FavoriteButton({
    super.key,
    required this.isSaved,
    required this.onTap,
    this.size = 20,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      HapticFeedback.lightImpact();
      onTap();
    }

    final button = GestureDetector(
      onTap: handleTap,
      child: AnimatedScale(
        scale: isSaved ? 1.15 : 1.0,
        duration: VeyraTokens.durationFast,
        curve: Curves.elasticOut,
        child: AnimatedSwitcher(
          duration: VeyraTokens.durationFast,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isSaved),
            color: isSaved
                ? const Color(0xFFE53935)
                : Colors.white.withValues(alpha: 0.9),
            size: size,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );

    if (!showBackground) return button;

    return GestureDetector(
      onTap: handleTap,
      child: AnimatedContainer(
        duration: VeyraTokens.durationFast,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSaved
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: isSaved ? 1.15 : 1.0,
          duration: VeyraTokens.durationFast,
          curve: Curves.elasticOut,
          child: AnimatedSwitcher(
            duration: VeyraTokens.durationFast,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isSaved),
              color: isSaved
                  ? const Color(0xFFE53935)
                  : Colors.white.withValues(alpha: 0.9),
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

/// Rating badge pill.
class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final bool dark;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VeyraTokens.spaceSM,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withValues(alpha: 0.55) : Colors.white,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
        boxShadow: dark ? null : VeyraTokens.shadowSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: VeyraTokens.labelSmall.copyWith(
              color: dark ? Colors.white : VeyraTokens.lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (reviewCount != null) ...[
            Text(
              ' (${_fmt(reviewCount!)})',
              style: VeyraTokens.bodySmall.copyWith(
                color: dark
                    ? Colors.white.withValues(alpha: 0.7)
                    : VeyraTokens.lightSubtext,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

/// Amenity chip row.
class AmenityChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const AmenityChip({super.key, required this.label, this.icon});

  static IconData amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'pool':
        return Icons.pool_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'dining':
        return Icons.restaurant_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'ocean':
      case 'beach':
        return Icons.waves_rounded;
      case 'bar':
        return Icons.local_bar_rounded;
      case 'ac':
        return Icons.ac_unit_rounded;
      case 'butler':
        return Icons.room_service_rounded;
      case 'onsen':
        return Icons.hot_tub_rounded;
      case 'garden':
        return Icons.park_rounded;
      case 'diving':
        return Icons.scuba_diving_rounded;
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VeyraTokens.spaceSM + 2,
        vertical: VeyraTokens.spaceXS + 1,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
        border: Border.all(
          color: isDark
              ? VeyraTokens.darkBorder
              : VeyraTokens.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? amenityIcon(label),
            size: 13,
            color: scheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: VeyraTokens.labelSmall.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic shimmer skeleton placeholder block.
class ShimmerSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF22322F) : const Color(0xFFE4DFD7);
    final highlightColor = isDark ? const Color(0xFF324743) : const Color(0xFFF7F5EE);
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    return Shimmer.fromColors(
      enabled: !isTest,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(VeyraTokens.radiusMD),
        ),
      ),
    );
  }
}

/// Shimmer skeleton matching StayCard geometry.
class StayCardSkeleton extends StatelessWidget {
  const StayCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        boxShadow: VeyraTokens.shadowSM,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 16 / 11,
            child: ShimmerSkeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VeyraTokens.spaceMD,
                vertical: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerSkeleton(
                    width: 150,
                    height: 14,
                    borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                  ),
                  ShimmerSkeleton(
                    width: 100,
                    height: 11,
                    borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                  ),
                  Row(
                    children: [
                      ShimmerSkeleton(
                        width: 55,
                        height: 16,
                        borderRadius:
                            BorderRadius.circular(VeyraTokens.radiusSM),
                      ),
                      const SizedBox(width: 6),
                      ShimmerSkeleton(
                        width: 35,
                        height: 11,
                        borderRadius:
                            BorderRadius.circular(VeyraTokens.radiusSM),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton matching FeaturedStayCard geometry.
class FeaturedStayCardSkeleton extends StatelessWidget {
  const FeaturedStayCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: VeyraTokens.spaceMD),
      child: ShimmerSkeleton(
        width: 280,
        height: 252,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
      ),
    );
  }
}

/// Responsive grid skeleton for card loading states.
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  const GridSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 500;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 1 : 2,
        crossAxisSpacing: VeyraTokens.spaceMD,
        mainAxisSpacing: VeyraTokens.spaceMD,
        childAspectRatio: isCompact ? 1.12 : 0.76,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const StayCardSkeleton(),
    );
  }
}

/// Loading state featuring elegant shimmer skeleton cards.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: VeyraTokens.spaceMD),
        child: GridSkeleton(itemCount: 4),
      ),
    );
  }
}

/// Empty state with icon, title, subtitle.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VeyraTokens.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: VeyraTokens.spaceLG),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VeyraTokens.spaceSM),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: VeyraTokens.spaceLG),
              AppButton(
                label: actionLabel!,
                onTap: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with retry button.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Something went wrong',
      subtitle: message,
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry,
    );
  }
}
