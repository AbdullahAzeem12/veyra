import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/booking.dart';
import '../../features/trips/booking_controller.dart';
import '../../app.dart';
import 'widgets/trip_itinerary_sheet.dart';
import '../profile/widgets/profile_sheets.dart';

/// Screen E — My Trips
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.bookingCtrlOf(context);
    if (ctrl == null) return const LoadingState();
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => _TripsBody(ctrl: ctrl),
    );
  }
}

class _TripsBody extends StatefulWidget {
  final BookingController ctrl;
  const _TripsBody({required this.ctrl});

  @override
  State<_TripsBody> createState() => _TripsBodyState();
}

class _TripsBodyState extends State<_TripsBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TripsHeader(),
            _TripsTabs(tabCtrl: _tabCtrl),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _TripsList(
                    bookings: widget.ctrl.upcomingBookings,
                    emptyTitle: 'No upcoming trips',
                    emptySubtitle: 'Book a stay to see it here.',
                    ctrl: widget.ctrl,
                  ),
                  _TripsList(
                    bookings: widget.ctrl.pastBookings,
                    emptyTitle: 'No past trips',
                    emptySubtitle: 'Your completed trips will appear here.',
                    ctrl: widget.ctrl,
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

class _TripsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VeyraTokens.spaceMD,
        VeyraTokens.spaceLG,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceSM,
      ),
      child: Row(
        children: [
          Text('My Trips', style: Theme.of(context).textTheme.displaySmall),
          const Spacer(),
          IconButton(
            tooltip: 'VIP Concierge Desk',
            icon: Icon(
              Icons.support_agent_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ConciergeChatSheet.show(context);
            },
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.luggage_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _TripsTabs extends StatelessWidget {
  final TabController tabCtrl;
  const _TripsTabs({required this.tabCtrl});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabCtrl,
      labelColor: Theme.of(context).colorScheme.primary,
      tabs: const [
        Tab(text: 'Upcoming'),
        Tab(text: 'Past'),
      ],
    );
  }
}

class _TripsList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyTitle;
  final String emptySubtitle;
  final BookingController ctrl;

  const _TripsList({
    required this.bookings,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.travel_explore_rounded,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: 'Explore Stays',
        onAction: () => Navigator.of(context).popUntil((r) => r.isFirst),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      itemCount: bookings.length,
      itemBuilder: (context, i) => _TripCard(booking: bookings[i], ctrl: ctrl),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  final BookingController ctrl;

  const _TripCard({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
        boxShadow: VeyraTokens.shadowSM,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
          onTap: () {
            HapticFeedback.lightImpact();
            TripItinerarySheet.show(context, booking, ctrl);
          },
          child: Column(
            children: [
              _TripCardImage(booking: booking),
              _TripCardDetails(booking: booking, ctrl: ctrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripCardImage extends StatelessWidget {
  final Booking booking;
  const _TripCardImage({required this.booking});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(VeyraTokens.radiusXL),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: booking.stayImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: booking.stayImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerSkeleton(
                  borderRadius: BorderRadius.zero,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.hotel_rounded, size: 48),
              ),
      ),
    );
  }
}

class _TripCardDetails extends StatelessWidget {
  final Booking booking;
  final BookingController ctrl;

  const _TripCardDetails({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TripCardHeader(booking: booking),
          const SizedBox(height: VeyraTokens.spaceXS),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                '${fmt.format(booking.checkIn)} → ${fmt.format(booking.checkOut)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people_rounded, size: 14, color: scheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}  ·  ${booking.nights} nights',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: VeyraTokens.spaceSM),
              Text(
                booking.price.totalDisplay,
                style: VeyraTokens.labelLarge.copyWith(color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VeyraTokens.deepEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text('Digital Pass & Route'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    TripItinerarySheet.show(context, booking, ctrl);
                  },
                ),
              ),
              if (booking.isCancellable) ...[
                const SizedBox(width: VeyraTokens.spaceSM),
                _CancelButton(booking: booking, ctrl: ctrl),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TripCardHeader extends StatelessWidget {
  final Booking booking;
  const _TripCardHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            booking.stayTitle,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: VeyraTokens.spaceSM),
        _StatusBadge(status: booking.status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatus.confirmed:
        color = Colors.green;
      case BookingStatus.pending:
        color = Colors.orange;
      case BookingStatus.cancelled:
        color = Colors.red;
      case BookingStatus.completed:
        color = Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VeyraTokens.spaceSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: VeyraTokens.labelSmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final Booking booking;
  final BookingController ctrl;
  const _CancelButton({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmCancel(context),
      icon: const Icon(Icons.cancel_outlined, size: 16),
      label: const Text('Cancel booking'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'Cancel your stay at ${booking.stayTitle}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.cancelBooking(booking.id);
            },
            child: Text(
              'Yes, cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
