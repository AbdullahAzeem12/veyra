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
        ? VeyraTokens.shadowLG
        : VeyraTokens.shadowMD;

    Widget card = AnimatedContainer(
      duration: VeyraTokens.durationFast,
      transform: widget.showPremiumDepth && _pressed
          ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        boxShadow: shadows,
        color: widget.isDark
            ? VeyraTokens.darkCardSurface
            : VeyraTokens.lightSurface,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.child,
    );

    if (!widget.showPremiumDepth) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
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
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VeyraTokens.spaceSM,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
            ),
            child: Text(
              stay.category,
              style: VeyraTokens.labelSmall.copyWith(color: Colors.white),
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
    return GestureDetector(
      onTap: onTap,
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
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Info overlay
            Positioned(
              left: VeyraTokens.spaceMD,
              right: VeyraTokens.spaceMD,
              bottom: VeyraTokens.spaceMD,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${stay.destination}, ${stay.country}',
          style: VeyraTokens.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          stay.title,
          style: VeyraTokens.headlineMedium.copyWith(color: Colors.white),
          maxLines: 2,
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
                  ),
                );
              },
            ),
            Text(
              '/night',
              style: VeyraTokens.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
