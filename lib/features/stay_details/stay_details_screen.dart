import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/stay.dart';
import '../../data/models/booking.dart';
import '../../data/demo/demo_data.dart';
import '../../features/trips/booking_controller.dart';
import '../../app.dart';
import 'package:intl/intl.dart';
import 'widgets/stay_details_sheets.dart';
import '../profile/widgets/profile_sheets.dart';

/// Screen C — Stay Details
class StayDetailsScreen extends StatefulWidget {
  final String stayId;
  final String? heroTag;
  const StayDetailsScreen({super.key, required this.stayId, this.heroTag});

  @override
  State<StayDetailsScreen> createState() => _StayDetailsScreenState();
}

class _StayDetailsScreenState extends State<StayDetailsScreen> {
  Stay? _stay;
  int _galleryIndex = 0;
  BookingController? _bookingCtrl;

  @override
  void initState() {
    super.initState();
    _stay = DemoData.stayById(widget.stayId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingCtrl ??= AppScope.bookingCtrlOf(context);
    _bookingCtrl?.resetBookingForm();
  }

  @override
  Widget build(BuildContext context) {
    final stay = _stay;
    if (stay == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorState(message: 'Stay not found'),
      );
    }
    final heroTag = widget.heroTag ?? 'stay_image_${stay.id}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= VeyraTokens.mediumBreakpoint;
        return isWide
            ? _WideLayout(
                stay: stay,
                galleryIndex: _galleryIndex,
                onGalleryChange: (i) => setState(() => _galleryIndex = i),
                bookingCtrl: _bookingCtrl,
                heroTag: heroTag,
              )
            : _CompactLayout(
                stay: stay,
                galleryIndex: _galleryIndex,
                onGalleryChange: (i) => setState(() => _galleryIndex = i),
                bookingCtrl: _bookingCtrl,
                heroTag: heroTag,
              );
      },
    );
  }
}

// ── Compact (phone) layout ────────────────────────────────────────────────────

class _CompactLayout extends StatelessWidget {
  final Stay stay;
  final int galleryIndex;
  final ValueChanged<int> onGalleryChange;
  final BookingController? bookingCtrl;
  final String heroTag;

  const _CompactLayout({
    required this.stay,
    required this.galleryIndex,
    required this.onGalleryChange,
    this.bookingCtrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _GalleryAppBar(
            stay: stay,
            galleryIndex: galleryIndex,
            onGalleryChange: onGalleryChange,
            heroTag: heroTag,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _PropertyInfo(stay: stay),
                const Divider(),
                _AmenitiesSection(amenities: stay.amenities, stay: stay),
                const Divider(),
                _HostInfo(stay: stay),
                const Divider(),
                if (bookingCtrl != null)
                  _BookingPanel(stay: stay, bookingCtrl: bookingCtrl!),
                const SizedBox(height: VeyraTokens.space2XL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wide (tablet/desktop) layout ─────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final Stay stay;
  final int galleryIndex;
  final ValueChanged<int> onGalleryChange;
  final BookingController? bookingCtrl;
  final String heroTag;

  const _WideLayout({
    required this.stay,
    required this.galleryIndex,
    required this.onGalleryChange,
    this.bookingCtrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stay.title),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              ShareStaySheet.show(context, stay);
            },
          ),
          _SaveButton(stay: stay),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _GalleryViewWide(
                    stay: stay,
                    galleryIndex: galleryIndex,
                    onGalleryChange: onGalleryChange,
                    heroTag: heroTag,
                  ),
                  _PropertyInfo(stay: stay),
                  const Divider(),
                  _AmenitiesSection(amenities: stay.amenities, stay: stay),
                  const Divider(),
                  _HostInfo(stay: stay),
                  const SizedBox(height: VeyraTokens.spaceLG),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 380,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              child: bookingCtrl != null
                  ? _BookingPanel(stay: stay, bookingCtrl: bookingCtrl!)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gallery components ────────────────────────────────────────────────────────

class _GalleryAppBar extends StatelessWidget {
  final Stay stay;
  final int galleryIndex;
  final ValueChanged<int> onGalleryChange;
  final String heroTag;

  const _GalleryAppBar({
    required this.stay,
    required this.galleryIndex,
    required this.onGalleryChange,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      stretchTriggerOffset: 90,
      backgroundColor: Colors.transparent,
      leading: _BackButton(),
      actions: [
        _ShareButton(stay: stay),
        _SaveButton(stay: stay),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: _GalleryView(
          stay: stay,
          galleryIndex: galleryIndex,
          onGalleryChange: onGalleryChange,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceXS),
      child: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final Stay stay;
  const _ShareButton({required this.stay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceXS),
      child: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            ShareStaySheet.show(context, stay);
          },
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final Stay stay;
  const _SaveButton({required this.stay});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = AppScope.savedCtrlOf(context);
    final saved = savedCtrl?.isSaved(stay.id) ?? false;
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceXS),
      child: FavoriteButton(
        isSaved: saved,
        onTap: () {
          HapticFeedback.lightImpact();
          savedCtrl?.toggleSaved(stay.id);
        },
      ),
    );
  }
}

class _GalleryView extends StatelessWidget {
  final Stay stay;
  final int galleryIndex;
  final ValueChanged<int> onGalleryChange;
  final String heroTag;

  const _GalleryView({
    required this.stay,
    required this.galleryIndex,
    required this.onGalleryChange,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    if (stay.imageUrls.isEmpty) {
      return Container(color: Colors.grey.shade300);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: stay.imageUrls.length,
          onPageChanged: onGalleryChange,
          itemBuilder: (_, i) {
            final tag = i == 0 ? heroTag : 'stay_img_${stay.id}_$i';
            final url = stay.imageUrls[i];
            return Hero(
              tag: tag,
              createRectTween: (begin, end) =>
                  MaterialRectArcTween(begin: begin, end: end),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerSkeleton(
                  borderRadius: BorderRadius.zero,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: VeyraTokens.spaceMD,
          left: 0,
          right: 0,
          child: _GalleryDots(
            count: stay.imageUrls.length,
            activeIndex: galleryIndex,
          ),
        ),
      ],
    );
  }
}

class _GalleryViewWide extends StatelessWidget {
  final Stay stay;
  final int galleryIndex;
  final ValueChanged<int> onGalleryChange;
  final String heroTag;

  const _GalleryViewWide({
    required this.stay,
    required this.galleryIndex,
    required this.onGalleryChange,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _GalleryView(
        stay: stay,
        galleryIndex: galleryIndex,
        onGalleryChange: onGalleryChange,
        heroTag: heroTag,
      ),
    );
  }
}

class _GalleryDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _GalleryDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: VeyraTokens.durationFast,
          width: i == activeIndex ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: i == activeIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          ),
        ),
      ),
    );
  }
}

// ── Property info ─────────────────────────────────────────────────────────────

class _PropertyInfo extends StatelessWidget {
  final Stay stay;
  const _PropertyInfo({required this.stay});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stay.title, style: tt.displaySmall),
          const SizedBox(height: VeyraTokens.spaceXS),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${stay.destination}, ${stay.country}',
                  style: tt.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: VeyraTokens.spaceSM),
              InkWell(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                onTap: () {
                  HapticFeedback.lightImpact();
                  StayReviewsSheet.show(context, stay);
                },
                child: RatingBadge(rating: stay.rating, reviewCount: stay.reviewCount),
              ),
            ],
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Text(stay.description, style: tt.bodyMedium),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  final List<String> amenities;
  final Stay stay;
  const _AmenitiesSection({required this.amenities, required this.stay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Amenities & Luxuries',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AllAmenitiesSheet.show(context, stay);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View all (20+)'),
              ),
            ],
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          Wrap(
            spacing: VeyraTokens.spaceSM,
            runSpacing: VeyraTokens.spaceSM,
            children: amenities.map((a) => InkWell(
              borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
              onTap: () {
                HapticFeedback.lightImpact();
                AllAmenitiesSheet.show(context, stay);
              },
              child: AmenityChip(label: a),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _HostInfo extends StatelessWidget {
  final Stay stay;
  const _HostInfo({required this.stay});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: stay.hostAvatarUrl.isNotEmpty
                    ? NetworkImage(stay.hostAvatarUrl)
                    : null,
                child: stay.hostAvatarUrl.isEmpty
                    ? const Icon(Icons.person_rounded, size: 24)
                    : null,
              ),
              const SizedBox(width: VeyraTokens.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hosted by', style: tt.bodySmall),
                    Text(
                      stay.hostName,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VeyraTokens.spaceSM),
              Chip(
                label: Text('Up to ${stay.maxGuests} guests'),
                avatar: const Icon(Icons.people_rounded, size: 16),
              ),
            ],
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
            icon: const Icon(Icons.support_agent_rounded, size: 18),
            label: const Text('Contact Villa Host & Concierge'),
            onPressed: () {
              HapticFeedback.lightImpact();
              ConciergeChatSheet.show(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Booking Panel ─────────────────────────────────────────────────────────────

class _BookingPanel extends StatelessWidget {
  final Stay stay;
  final BookingController bookingCtrl;

  const _BookingPanel({required this.stay, required this.bookingCtrl});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bookingCtrl,
      builder: (context, _) {
        if (bookingCtrl.step == BookingStep.confirmed) {
          return _BookingConfirmation(booking: bookingCtrl.confirmedBooking!);
        }
        return _BookingForm(stay: stay, bookingCtrl: bookingCtrl);
      },
    );
  }
}

class _BookingForm extends StatelessWidget {
  final Stay stay;
  final BookingController bookingCtrl;

  const _BookingForm({required this.stay, required this.bookingCtrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = bookingCtrl.computePrice(stay.nightlyPriceCents);
    return Container(
      margin: const EdgeInsets.all(VeyraTokens.spaceMD),
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
        boxShadow: VeyraTokens.shadowMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PriceHeader(stay: stay),
          const SizedBox(height: VeyraTokens.spaceMD),
          _DateSelector(bookingCtrl: bookingCtrl),
          const SizedBox(height: VeyraTokens.spaceSM),
          _GuestSelector(stay: stay, bookingCtrl: bookingCtrl),
          AnimatedSize(
            duration: VeyraTokens.durationNormal,
            curve: Curves.easeInOutCubic,
            child: price != null
                ? Column(
                    children: [
                      const Divider(height: VeyraTokens.spaceLG),
                      _PriceBreakdown(price: price),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VeyraTokens.deepEmerald,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text(
              'Customize VIP Bespoke Booking',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              MultiStepBookingSheet.show(context, stay, bookingCtrl);
            },
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          AppButton(
            label: 'Quick Instant Reserve',
            isLoading: bookingCtrl.step == BookingStep.submitting,
            onTap: () => bookingCtrl.submitBooking(stay, 'guest'),
          ),
          if (bookingCtrl.generalError != null)
            Padding(
              padding: const EdgeInsets.only(top: VeyraTokens.spaceSM),
              child: Text(
                bookingCtrl.generalError!,
                style: TextStyle(color: scheme.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceHeader extends StatelessWidget {
  final Stay stay;
  const _PriceHeader({required this.stay});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currencyCtrl = AppScope.currencyCtrlOf(context);
    final priceStr = currencyCtrl != null
        ? currencyCtrl.formatCents(stay.nightlyPriceCents)
        : stay.nightlyPriceDisplay;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          priceStr,
          style: VeyraTokens.displaySmall.copyWith(color: scheme.primary),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(' / night', style: Theme.of(context).textTheme.bodySmall),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
          onTap: () {
            HapticFeedback.lightImpact();
            StayReviewsSheet.show(context, stay);
          },
          child: RatingBadge(rating: stay.rating),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final BookingController bookingCtrl;
  const _DateSelector({required this.bookingCtrl});

  Future<void> _pickDate(BuildContext context, bool isCheckIn) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (bookingCtrl.checkIn ?? now.add(const Duration(days: 1)))
          : (bookingCtrl.checkOut ?? now.add(const Duration(days: 2))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      HapticFeedback.lightImpact();
      if (isCheckIn) {
        bookingCtrl.setCheckIn(picked);
      } else {
        bookingCtrl.setCheckOut(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd');
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'Check-in',
            value: bookingCtrl.checkIn != null ? fmt.format(bookingCtrl.checkIn!) : null,
            error: bookingCtrl.checkInError,
            onTap: () => _pickDate(context, true),
          ),
        ),
        const SizedBox(width: VeyraTokens.spaceSM),
        Expanded(
          child: _DateField(
            label: 'Check-out',
            value: bookingCtrl.checkOut != null ? fmt.format(bookingCtrl.checkOut!) : null,
            error: bookingCtrl.checkOutError,
            onTap: () => _pickDate(context, false),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final String? error;
  final VoidCallback onTap;
  const _DateField({required this.label, this.value, this.error, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(VeyraTokens.spaceSM),
        decoration: BoxDecoration(
          color: isDark ? VeyraTokens.darkBackground : VeyraTokens.lightCardSurface,
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          border: Border.all(
            color: error != null ? scheme.error : scheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              value ?? 'Select',
              style: value != null
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodySmall,
            ),
            if (error != null)
              Text(error!, style: TextStyle(color: scheme.error, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _GuestSelector extends StatelessWidget {
  final Stay stay;
  final BookingController bookingCtrl;
  const _GuestSelector({required this.stay, required this.bookingCtrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people_rounded, size: 18),
        const SizedBox(width: VeyraTokens.spaceSM),
        Text('Guests', style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        _SmallCounter(
          value: bookingCtrl.guests,
          min: 1,
          max: stay.maxGuests,
          onChanged: bookingCtrl.setGuests,
        ),
        if (bookingCtrl.guestError != null)
          Text(
            bookingCtrl.guestError!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

class _SmallCounter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _SmallCounter({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          onPressed: value > min
              ? () {
                  HapticFeedback.lightImpact();
                  onChanged(value - 1);
                }
              : null,
        ),
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          onPressed: value < max
              ? () {
                  HapticFeedback.lightImpact();
                  onChanged(value + 1);
                }
              : null,
        ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final BookingPrice price;
  const _PriceBreakdown({required this.price});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _PriceRow(
          '${price.nightlyPriceDisplay} × ${price.nights} nights',
          price.nightlySubtotalDisplay,
          tt,
        ),
        _PriceRow('Cleaning fee', price.cleaningFeeDisplay, tt),
        _PriceRow('Service fee', price.serviceFeeDisplay, tt),
        if (price.discountCents > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(VeyraTokens.radiusXS),
                  ),
                  child: Text(
                    'Seasonal discount (15%)',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  price.discountDisplay,
                  style: tt.bodyLarge?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        _PriceRow('Occupancy taxes (8%)', price.taxesDisplay, tt),
        const Divider(height: VeyraTokens.spaceLG),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: tt.titleSmall),
                Text('Includes taxes & fees', style: tt.bodySmall),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: VeyraTokens.durationFast,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                price.totalDisplay,
                key: ValueKey<String>(price.totalDisplay),
                style: VeyraTokens.headlineLarge.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme tt;
  const _PriceRow(this.label, this.value, this.tt);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: tt.bodyMedium),
          const Spacer(),
          Text(value, style: tt.bodyLarge),
        ],
      ),
    );
  }
}

class _BookingConfirmation extends StatelessWidget {
  final Booking booking;
  const _BookingConfirmation({required this.booking});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM dd, yyyy');
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: 1),
            builder: (_, v, __) => Transform.scale(
              scale: v,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 40, color: scheme.primary),
              ),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Text('Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: VeyraTokens.spaceXS),
          Text(
            booking.bookingReference,
            style: VeyraTokens.displaySmall.copyWith(
              color: scheme.secondary,
              fontFamily: VeyraTokens.fontDisplay,
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Text(
            '${fmt.format(booking.checkIn)} → ${fmt.format(booking.checkOut)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          Text(
            booking.price.totalDisplay,
            style: VeyraTokens.headlineLarge.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: VeyraTokens.spaceLG),
          AppButton(
            label: 'View My Trips',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
