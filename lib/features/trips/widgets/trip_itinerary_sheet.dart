import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/booking.dart';
import '../booking_controller.dart';
import '../../profile/widgets/profile_sheets.dart';

class TripItinerarySheet extends StatelessWidget {
  final Booking booking;
  final BookingController ctrl;

  const TripItinerarySheet({
    super.key,
    required this.booking,
    required this.ctrl,
  });

  static void show(BuildContext context, Booking booking, BookingController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripItinerarySheet(booking: booking, ctrl: ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('EEE, MMM dd, yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VeyraTokens.spaceMD,
              vertical: VeyraTokens.spaceSM,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP Itinerary Pass',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Reference: ${booking.bookingReference}',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              children: [
                // Digital Boarding Pass Ticket
                _BoardingPassCard(booking: booking),
                const SizedBox(height: VeyraTokens.spaceLG),

                // VIP Amenities & Key Inclusions
                Text(
                  'Reserved Inclusions & Perks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: VeyraTokens.spaceSM),
                _InclusionTile(
                  icon: Icons.airport_shuttle_rounded,
                  title: 'Private Chauffeur Meet & Greet',
                  subtitle: 'Terminal arrival pickup with luggage escort',
                ),
                _InclusionTile(
                  icon: Icons.key_rounded,
                  title: 'Biometric Mobile Room Key',
                  subtitle: 'Instant check-in bypassing reception desk',
                ),
                _InclusionTile(
                  icon: Icons.room_service_rounded,
                  title: '24/7 Dedicated Concierge & Butler',
                  subtitle: 'Direct messaging channel on demand',
                ),
                _InclusionTile(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Artisan Breakfast Daily',
                  subtitle: 'Served at rooftop terrace or in-suite dining',
                ),

                const SizedBox(height: VeyraTokens.spaceLG),

                // Action Brain Buttons
                Text(
                  'Quick Travel Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: VeyraTokens.spaceSM),
                _ActionButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Add to Apple / Google Calendar',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${booking.stayTitle} added to your device calendar (${fmt.format(booking.checkIn)})',
                        ),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.navigation_rounded,
                  label: 'Request Chauffeur / Open Directions',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showDirectionsDialog(context);
                  },
                ),
                _ActionButton(
                  icon: Icons.support_agent_rounded,
                  label: 'Connect with VIP Concierge Desk',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    ConciergeChatSheet.show(context);
                  },
                ),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share Boarding Pass & Itinerary',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(
                      text: 'Veyra VIP Pass: ${booking.stayTitle}\nDates: ${fmt.format(booking.checkIn)} - ${fmt.format(booking.checkOut)}\nReference: ${booking.bookingReference}',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Itinerary pass copied to clipboard!')),
                    );
                  },
                ),

                if (booking.isCancellable) ...[
                  const SizedBox(height: VeyraTokens.spaceMD),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel Reservation & Process Refund'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _confirmCancellation(context);
                    },
                  ),
                ],
                const SizedBox(height: VeyraTokens.spaceXL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDirectionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions_car_rounded, color: VeyraTokens.deepEmerald),
            SizedBox(width: 8),
            Text('Chauffeur Route'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destination: ${booking.stayTitle}'),
            const SizedBox(height: 8),
            const Text(
              'Your private driver has been alerted. Estimated transfer time: 24 minutes. Meet at the VIP Arrival Lounge Bay 3.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VeyraTokens.deepEmerald,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chauffeur navigation dispatched to vehicle.')),
              );
            },
            child: const Text('Confirm Pickup'),
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text(
          'Cancel your stay at ${booking.stayTitle}? A full 100% refund of ${booking.price.totalDisplay} will be processed back to your original payment card.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Reservation'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
              ctrl.cancelBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reservation ${booking.bookingReference} cancelled. Refund issued.'),
                ),
              );
            },
            child: Text(
              'Confirm Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardingPassCard extends StatelessWidget {
  final Booking booking;
  const _BoardingPassCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final fmtDate = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
        boxShadow: VeyraTokens.shadowMD,
      ),
      child: Column(
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A34), const Color(0xFF12221E)]
                    : [VeyraTokens.deepEmerald, const Color(0xFF0F3A30)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VEYRA PRIVATE ESCAPES',
                        style: TextStyle(
                          color: VeyraTokens.premiumGold,
                          letterSpacing: 2,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.stayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PassDetail(
                      label: 'CHECK-IN',
                      value: fmtDate.format(booking.checkIn),
                      subtitle: 'From 3:00 PM',
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                    _PassDetail(
                      label: 'CHECK-OUT',
                      value: fmtDate.format(booking.checkOut),
                      subtitle: 'Until 11:00 AM',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PassDetail(
                      label: 'GUESTS',
                      value: '${booking.guestCount} VIPs',
                    ),
                    _PassDetail(
                      label: 'DURATION',
                      value: '${booking.nights} Nights',
                    ),
                    _PassDetail(
                      label: 'AMOUNT PAID',
                      value: booking.price.totalDisplay,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Perforated Barcode / QR Simulation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Simulated QR matrix
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.black,
                          size: 44,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DIGITAL SUITE KEYPASS',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.bookingReference,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'Scan at entrance NFC terminal',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassDetail extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _PassDetail({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}

class _InclusionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InclusionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: VeyraTokens.deepEmerald.withValues(alpha: 0.12),
            child: Icon(icon, color: VeyraTokens.deepEmerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          side: BorderSide(
            color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
          ),
        ),
        leading: Icon(icon, color: VeyraTokens.deepEmerald, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
