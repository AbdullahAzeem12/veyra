import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/stay.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../scope/app_scope.dart';

/// Premium stay card used in grids and lists.
/// Uses a Hero tag on the image with MaterialRectArcTween for smooth page transitions.
class StayCard extends StatelessWidget {
  final Stay stay;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool showPremiumDepth;
  final double aspectRatio;
  final String? heroTag;

  const StayCard({
    super.key,
    required this.stay,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
    this.showPremiumDepth = false,
    this.aspectRatio = 3 / 4,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: _CardContainer(
        isDark: isDark,
        showPremiumDepth: showPremiumDepth,
        child: _CardContent(
          stay: stay,
          isSaved: isSaved,
          onFavoriteTap: onFavoriteTap,
          isDark: isDark,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _CardContainer extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final bool showPremiumDepth;

  const _CardContainer({
    required this.child,
    required this.isDark,
    required this.showPremiumDepth,
  });

  @override
  State<_CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<_CardContainer> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final shadows = widget.showPremiumDepth
        ? [
            ...VeyraTokens.shadowLG,
            BoxShadow(
              color: VeyraTokens.deepEmerald.withValues(alpha: widget.isDark ? 0.35 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
        : VeyraTokens.shadowMD;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      transform: _pressed
          ? (Matrix4.diagonal3Values(0.975, 0.975, 1.0)
            ..setTranslationRaw(0, 2, 0))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        boxShadow: shadows,
        color: widget.isDark
            ? VeyraTokens.darkCardSurface
            : VeyraTokens.lightSurface,
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : VeyraTokens.lightBorder,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.child,
    );

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: card,
    );
  }
}

class _CardContent extends StatelessWidget {
  final Stay stay;
  final bool isSaved;
  final VoidCallback onFavoriteTap;
  final bool isDark;
  final String? heroTag;

  const _CardContent({
    required this.stay,
    required this.isSaved,
    required this.onFavoriteTap,
    required this.isDark,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: _CardImage(
                  stay: stay,
                  isSaved: isSaved,
                  onFavoriteTap: onFavoriteTap,
                  heroTag: heroTag,
                  useAspectRatio: false,
                ),
              ),
              Expanded(
                flex: 7,
                child: _CardDetails(
                  stay: stay,
                  isDark: isDark,
                  isCompact: constraints.maxHeight < 330,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardImage(
              stay: stay,
              isSaved: isSaved,
              onFavoriteTap: onFavoriteTap,
              heroTag: heroTag,
              useAspectRatio: true,
            ),
            _CardDetails(stay: stay, isDark: isDark),
          ],
        );
      },
    );
  }
}

class _CardImage extends StatelessWidget {
  final Stay stay;
  final bool isSaved;
  final VoidCallback onFavoriteTap;
  final String? heroTag;
  final bool useAspectRatio;

  const _CardImage({
    required this.stay,
    required this.isSaved,
    required this.onFavoriteTap,
    this.heroTag,
    this.useAspectRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: heroTag ?? 'stay_image_${stay.id}',
          createRectTween: (begin, end) =>
              MaterialRectArcTween(begin: begin, end: end),
          child: CachedNetworkImage(
            imageUrl: stay.primaryImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ShimmerSkeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported_rounded, size: 40),
            ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        // Category chip
        Positioned(
          top: VeyraTokens.spaceSM,
          left: VeyraTokens.spaceSM,
          child: VeyraGlassSurface(
            preset: VeyraGlassPreset.subtle,
            borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
            padding: const EdgeInsets.symmetric(
              horizontal: VeyraTokens.spaceSM + 2,
              vertical: 3.5,
            ),
            child: Text(
              stay.category,
              style: VeyraTokens.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        // Favourite button
        Positioned(
          top: VeyraTokens.spaceXS,
          right: VeyraTokens.spaceXS,
          child: FavoriteButton(
            isSaved: isSaved,
            onTap: onFavoriteTap,
            size: 18,
          ),
        ),
        // Rating badge
        Positioned(
          bottom: VeyraTokens.spaceSM,
          left: VeyraTokens.spaceSM,
          child: RatingBadge(rating: stay.rating, dark: true),
        ),
      ],
    );

    if (useAspectRatio) {
      return AspectRatio(
        aspectRatio: 16 / 11,
        child: stack,
      );
    }
    return stack;
  }
}

class _CardDetails extends StatelessWidget {
  final Stay stay;
  final bool isDark;
  final bool isCompact;

  const _CardDetails({
    required this.stay,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VeyraTokens.spaceMD,
        vertical: isCompact ? 6 : VeyraTokens.spaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            stay.title,
            style: tt.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${stay.destination}, ${stay.country}',
                  style: tt.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 2 : VeyraTokens.spaceSM),
          Row(
            children: [
              Builder(
                builder: (context) {
                  final currencyCtrl = AppScope.currencyCtrlOf(context);
                  final priceStr = currencyCtrl != null
                      ? currencyCtrl.formatCents(stay.nightlyPriceCents)
                      : stay.nightlyPriceDisplay;
                  return Text(
                    priceStr,
                    style: (isCompact ? tt.titleMedium : VeyraTokens.headlineMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? VeyraTokens.opalMint
                          : VeyraTokens.deepEmerald,
                    ),
                  );
                },
              ),
              Text(
                ' / night',
                style: tt.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal featured stay card for the hero carousel.
class FeaturedStayCard extends StatelessWidget {
  final Stay stay;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final String? heroTag;

  const FeaturedStayCard({
    super.key,
    required this.stay,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return VeyraPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: VeyraTokens.spaceMD),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
          boxShadow: VeyraTokens.shadowLG,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Full-cover hero image
            Positioned.fill(
              child: Hero(
                tag: heroTag ?? 'featured_stay_image_${stay.id}',
                createRectTween: (begin, end) =>
                    MaterialRectArcTween(begin: begin, end: end),
                child: CachedNetworkImage(
                  imageUrl: stay.primaryImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerSkeleton(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            // Bottom gradient
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
            // Info overlay with liquid glass morphism
            Positioned(
              left: VeyraTokens.spaceSM,
              right: VeyraTokens.spaceSM,
              bottom: VeyraTokens.spaceSM,
              child: _FeaturedCardInfo(stay: stay),
            ),
            // Favourite
            Positioned(
              top: VeyraTokens.spaceSM,
              right: VeyraTokens.spaceSM,
              child: FavoriteButton(
                isSaved: isSaved,
                onTap: onFavoriteTap,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCardInfo extends StatelessWidget {
  final Stay stay;
  const _FeaturedCardInfo({required this.stay});

  @override
  Widget build(BuildContext context) {
    return VeyraGlassSurface(
      preset: VeyraGlassPreset.floating,
      borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
      padding: const EdgeInsets.symmetric(
        horizontal: VeyraTokens.spaceMD - 2,
        vertical: VeyraTokens.spaceSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${stay.destination}, ${stay.country}',
            style: VeyraTokens.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            stay.title,
            style: VeyraTokens.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: VeyraTokens.spaceXS),
          Row(
            children: [
              RatingBadge(rating: stay.rating, dark: true),
              const Spacer(),
              Builder(
                builder: (context) {
                  final currencyCtrl = AppScope.currencyCtrlOf(context);
                  final priceStr = currencyCtrl != null
                      ? currencyCtrl.formatCents(stay.nightlyPriceCents)
                      : stay.nightlyPriceDisplay;
                  return Text(
                    priceStr,
                    style: VeyraTokens.labelLarge.copyWith(
                      color: VeyraTokens.antiqueGold,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              Text(
                '/night',
                style: VeyraTokens.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact luxury sanctuary card engineered for horizontal discovery carousels.
class LuxurySanctuaryCard extends StatelessWidget {
  final Stay stay;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final String? badgeText;
  final String? heroTag;

  const LuxurySanctuaryCard({
    super.key,
    required this.stay,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
    this.badgeText,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeroTag = heroTag ?? 'sanctuary_image_${stay.id}';
    return VeyraPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: VeyraTokens.spaceMD - 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
          boxShadow: VeyraTokens.shadowMD,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Hero(
              tag: effectiveHeroTag,
              createRectTween: (begin, end) =>
                  MaterialRectArcTween(begin: begin, end: end),
              child: CachedNetworkImage(
                imageUrl: stay.primaryImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerSkeleton(
                  borderRadius: BorderRadius.zero,
                ),
                errorWidget: (_, __, ___) => Container(color: Colors.grey.shade400),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),
            // Top Badge (Category / Highlight)
            Positioned(
              top: VeyraTokens.spaceSM,
              left: VeyraTokens.spaceSM,
              child: VeyraGlassSurface(
                preset: VeyraGlassPreset.subtle,
                borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                child: Text(
                  badgeText ?? stay.category,
                  style: VeyraTokens.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            // Favorite Button
            Positioned(
              top: VeyraTokens.spaceXS,
              right: VeyraTokens.spaceXS,
              child: FavoriteButton(
                isSaved: isSaved,
                onTap: onFavoriteTap,
                size: 16,
              ),
            ),
            // Bottom Glass Info Panel
            Positioned(
              left: VeyraTokens.spaceSM,
              right: VeyraTokens.spaceSM,
              bottom: VeyraTokens.spaceSM,
              child: VeyraGlassSurface(
                preset: VeyraGlassPreset.floating,
                borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stay.title,
                      style: VeyraTokens.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stay.destination}, ${stay.country}',
                      style: VeyraTokens.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBadge(rating: stay.rating, dark: true),
                        const Spacer(),
                        Builder(
                          builder: (context) {
                            final currencyCtrl = AppScope.currencyCtrlOf(context);
                            final priceStr = currencyCtrl != null
                                ? currencyCtrl.formatCents(stay.nightlyPriceCents)
                                : stay.nightlyPriceDisplay;
                            return Text(
                              priceStr,
                              style: VeyraTokens.labelSmall.copyWith(
                                color: VeyraTokens.antiqueGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        Text(
                          '/n',
                          style: VeyraTokens.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

