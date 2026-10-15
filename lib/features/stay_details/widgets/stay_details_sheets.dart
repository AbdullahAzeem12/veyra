import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../app.dart';
import '../../../data/models/stay.dart';
import '../../trips/booking_controller.dart';

// ── 1. All Amenities Modal Sheet ──────────────────────────────────────────────

class AllAmenitiesSheet extends StatelessWidget {
  final Stay stay;
  const AllAmenitiesSheet({super.key, required this.stay});

  static void show(BuildContext context, Stay stay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllAmenitiesSheet(stay: stay),
    );
  }

  static const Map<String, List<Map<String, dynamic>>> _categories = {
    'Wellness & Relaxation': [
      {'icon': Icons.pool_rounded, 'name': 'Infinity Edge Horizon Pool'},
      {'icon': Icons.hot_tub_rounded, 'name': 'Heated Hydrotherapy Jacuzzi'},
      {'icon': Icons.spa_rounded, 'name': 'Ayurvedic Private Spa Pavilion'},
      {'icon': Icons.fitness_center_rounded, 'name': 'Technogym Private Suite'},
    ],
    'Culinary & Refreshments': [
      {'icon': Icons.restaurant_rounded, 'name': 'Private Chef Kitchen & Dining'},
      {'icon': Icons.wine_bar_rounded, 'name': 'Curated Sommelier Wine Cellar'},
      {'icon': Icons.coffee_rounded, 'name': 'Espresso & Artisan Coffee Bar'},
      {'icon': Icons.outdoor_grill_rounded, 'name': 'Teppanyaki Sunset Terrace'},
    ],
    'Dedicated Services': [
      {'icon': Icons.support_agent_rounded, 'name': '24/7 Personal Villa Butler'},
      {'icon': Icons.flight_takeoff_rounded, 'name': 'Helicopter Runway Escort'},
      {'icon': Icons.cleaning_services_rounded, 'name': 'Twice-Daily Maid & Turn-down'},
      {'icon': Icons.security_rounded, 'name': 'Gated Private Security Liaison'},
    ],
    'Technology & Audio': [
      {'icon': Icons.wifi_rounded, 'name': 'Fiber Gigabit Mesh Wi-Fi'},
      {'icon': Icons.speaker_group_rounded, 'name': 'Sonos Multi-Room Sound System'},
      {'icon': Icons.tv_rounded, 'name': '85" 4K OLED Home Cinema'},
      {'icon': Icons.lock_outline_rounded, 'name': 'Biometric Smart Access'},
    ],
    'Outdoor & Scenery': [
      {'icon': Icons.beach_access_rounded, 'name': 'Direct Beachfront Cabana'},
      {'icon': Icons.flight_rounded, 'name': 'Private Helipad Access'},
      {'icon': Icons.fireplace_rounded, 'name': 'Open-Air Sunset Firepit'},
      {'icon': Icons.directions_boat_rounded, 'name': 'Deep-Water Private Yacht Mooring'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: Row(
              children: [
                Text('What this luxury stay offers',
                    style: Theme.of(context).textTheme.headlineMedium),
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
              children: _categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: VeyraTokens.spaceSM),
                    ...entry.value.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(item['icon'] as IconData,
                                    color: scheme.primary, size: 20),
                              ),
                              const SizedBox(width: VeyraTokens.spaceMD),
                              Expanded(
                                child: Text(item['name'] as String,
                                    style: Theme.of(context).textTheme.bodyLarge),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: VeyraTokens.spaceMD),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Stay Reviews & Verified Guest Ratings Sheet ───────────────────────────

class StayReviewsSheet extends StatelessWidget {
  final Stay stay;
  const StayReviewsSheet({super.key, required this.stay});

  static void show(BuildContext context, Stay stay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StayReviewsSheet(stay: stay),
    );
  }

  static const List<Map<String, dynamic>> _reviews = [
    {
      'author': 'Lord Alistair Sterling',
      'location': 'London, United Kingdom',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'date': 'October 2024',
      'tripType': 'Couples Anniversary',
      'text':
          'An utterly sublime sanctuary. The private butler anticipated every whim before we even voiced it. Sunset over the lagoon from the private cabana was unforgettable.',
    },
    {
      'author': 'Claire & David Montaigne',
      'location': 'Geneva, Switzerland',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'date': 'September 2024',
      'tripType': 'Luxury Vacation',
      'text':
          'Architectural perfection meets genuine warmth. The infinity pool blending into the horizon was magical. We will make this an annual retreat.',
    },
    {
      'author': 'Kenji Takahashi',
      'location': 'Tokyo, Japan',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      'date': 'August 2024',
      'tripType': 'Private Escape',
      'text':
          'The twin-engine helicopter landing directly on the private helipad was seamless. World-class dining curated by the private chef. 10/10.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 28),
                const SizedBox(width: 6),
                Text(
                  '${stay.rating} · 128 Verified Reviews',
                  style: Theme.of(context).textTheme.headlineMedium,
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
                // Category breakdown bars
                _RatingScoreRow(label: 'Cleanliness', score: 4.9),
                _RatingScoreRow(label: 'Accuracy & Integrity', score: 5.0),
                _RatingScoreRow(label: 'Concierge Communication', score: 4.9),
                _RatingScoreRow(label: 'Prime Location', score: 5.0),
                _RatingScoreRow(label: 'Luxury Value & Service', score: 4.8),

                const SizedBox(height: VeyraTokens.spaceLG),
                const Divider(),
                const SizedBox(height: VeyraTokens.spaceMD),
                Text('Guest Testimonials', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: VeyraTokens.spaceMD),
                ..._reviews.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: VeyraTokens.spaceLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(r['avatar'] as String),
                              ),
                              const SizedBox(width: VeyraTokens.spaceMD),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['author'] as String,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                  Text('${r['location']} · ${r['date']}',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: VeyraTokens.spaceSM),
                          Text(r['text'] as String, style: const TextStyle(height: 1.45)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingScoreRow extends StatelessWidget {
  final String label;
  final double score;
  const _RatingScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 5.0,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(VeyraTokens.deepEmerald),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(score.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── 3. Share Stay Sheet ───────────────────────────────────────────────────────

class ShareStaySheet extends StatelessWidget {
  final Stay stay;
  const ShareStaySheet({super.key, required this.stay});

  static void show(BuildContext context, Stay stay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareStaySheet(stay: stay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final url = 'https://veyra.travel/stays/${stay.id}';

    return Container(
      padding: const EdgeInsets.all(VeyraTokens.spaceLG),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: VeyraTokens.spaceMD),
          Text('Share this Luxury Escape',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('${stay.title} · ${stay.destination}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: VeyraTokens.spaceMD),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.copy_rounded)),
            title: const Text('Copy Private Link'),
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: url));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stay invitation link copied to clipboard!')),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.send_rounded)),
            title: const Text('Send to Concierge for Group Booking'),
            subtitle: const Text('Share directly with your VIP advisor'),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liaison notified for group reservation.')),
              );
            },
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
        ],
      ),
    );
  }
}

// ── 4. Multi-Step Luxury Booking & Add-ons Sheet ───────────────────────────────

class MultiStepBookingSheet extends StatefulWidget {
  final Stay stay;
  final BookingController bookingCtrl;

  const MultiStepBookingSheet({
    super.key,
    required this.stay,
    required this.bookingCtrl,
  });

  static void show(BuildContext context, Stay stay, BookingController bookingCtrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiStepBookingSheet(stay: stay, bookingCtrl: bookingCtrl),
    );
  }

  @override
  State<MultiStepBookingSheet> createState() => _MultiStepBookingSheetState();
}

class _MultiStepBookingSheetState extends State<MultiStepBookingSheet> {
  int _currentStep = 0; // 0: Dates & Guests, 1: Add-ons, 2: Payment & Confirm

  // Add-ons selection
  bool _helicopterTransfer = false;
  bool _vintageChampagne = true;
  bool _dedicatedButler = false;
  bool _sunsetYacht = false;

  final TextEditingController _specialRequestsCtrl = TextEditingController();

  int get _addOnsTotalCents {
    int total = 0;
    if (_helicopterTransfer) total += 45000;
    if (_vintageChampagne) total += 28000;
    if (_dedicatedButler) total += 35000 * ((widget.bookingCtrl.checkOut?.difference(widget.bookingCtrl.checkIn ?? DateTime.now()).inDays) ?? 1);
    if (_sunsetYacht) total += 85000;
    return total;
  }

  @override
  void dispose() {
    _specialRequestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final currencyCtrl = AppScope.currencyCtrlOf(context);
    final profileCtrl = AppScope.profileCtrlOf(context);

    final basePrice = widget.bookingCtrl.computePrice(widget.stay.nightlyPriceCents);
    final grandTotalCents = (basePrice?.totalCents ?? widget.stay.nightlyPriceCents) + _addOnsTotalCents;
    final grandTotalDisplay = currencyCtrl != null
        ? currencyCtrl.formatCents(grandTotalCents)
        : '\$${(grandTotalCents / 100).toStringAsFixed(0)}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
            padding: const EdgeInsets.all(VeyraTokens.spaceMD),
            child: Row(
              children: [
                if (_currentStep > 0 && _currentStep < 3)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: () => setState(() => _currentStep--),
                  ),
                Text(
                  _currentStep == 0
                      ? 'Reserve Your Sanctuary'
                      : _currentStep == 1
                          ? 'Curated Luxury Add-ons'
                          : _currentStep == 2
                              ? 'Payment & Special Requests'
                              : 'Reservation Confirmed',
                  style: Theme.of(context).textTheme.headlineMedium,
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

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              children: [
                if (_currentStep == 0) ...[
                  // Step 0: Dates & Guests
                  Text('Stay Dates', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: VeyraTokens.spaceSM),
                  _DateSelector(bookingCtrl: widget.bookingCtrl),
                  const SizedBox(height: VeyraTokens.spaceMD),
                  _GuestSelector(stay: widget.stay, bookingCtrl: widget.bookingCtrl),
                  const SizedBox(height: VeyraTokens.spaceLG),
                  if (basePrice != null) ...[
                    Text('Price Calculation', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: VeyraTokens.spaceSM),
                    _PriceBreakdown(price: basePrice),
                  ],
                ] else if (_currentStep == 1) ...[
                  // Step 1: Add-ons
                  Text('Elevate Your Experience', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text('Select bespoke services for your arrival', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: VeyraTokens.spaceMD),
                  CheckboxListTile.adaptive(
                    value: _helicopterTransfer,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _helicopterTransfer = val ?? false);
                    },
                    secondary: const Icon(Icons.flight_takeoff_rounded, color: VeyraTokens.deepEmerald),
                    title: const Text('Twin-Engine Helicopter Transfer'),
                    subtitle: const Text('Runway-to-helipad direct transfer (+\$450)'),
                  ),
                  const Divider(),
                  CheckboxListTile.adaptive(
                    value: _vintageChampagne,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _vintageChampagne = val ?? false);
                    },
                    secondary: const Icon(Icons.wine_bar_rounded, color: VeyraTokens.antiqueGold),
                    title: const Text('Chilled Dom Pérignon on Arrival'),
                    subtitle: const Text('Placed in master suite with artisan truffles (+\$280)'),
                  ),
                  const Divider(),
                  CheckboxListTile.adaptive(
                    value: _dedicatedButler,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _dedicatedButler = val ?? false);
                    },
                    secondary: const Icon(Icons.support_agent_rounded, color: Colors.blueAccent),
                    title: const Text('24/7 Dedicated Private Butler'),
                    subtitle: const Text('Personal concierge & packing service (+\$350/night)'),
                  ),
                  const Divider(),
                  CheckboxListTile.adaptive(
                    value: _sunsetYacht,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _sunsetYacht = val ?? false);
                    },
                    secondary: const Icon(Icons.directions_boat_rounded, color: Colors.teal),
                    title: const Text('Sunset Riva Yacht Charter'),
                    subtitle: const Text('4-hour private cruise with sommelier (+\$850)'),
                  ),
                ] else if (_currentStep == 2) ...[
                  // Step 2: Payment & Final Review
                  Text('Payment Method', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: VeyraTokens.spaceSM),
                  Container(
                    padding: const EdgeInsets.all(VeyraTokens.spaceMD),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                      border: Border.all(color: scheme.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card_rounded, color: scheme.primary),
                        const SizedBox(width: VeyraTokens.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profileCtrl?.defaultCard != null
                                  ? '${profileCtrl!.defaultCard!.brand} •••• ${profileCtrl.defaultCard!.last4}'
                                  : 'Mastercard •••• 4821'),
                              Text('Default VIP payment card', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: VeyraTokens.deepEmerald),
                      ],
                    ),
                  ),
                  const SizedBox(height: VeyraTokens.spaceLG),
                  Text('Special Requests to Butler / Front Desk', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: VeyraTokens.spaceSM),
                  TextField(
                    controller: _specialRequestsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. Hypoallergenic feather pillows, celebration flowers...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(VeyraTokens.radiusMD)),
                    ),
                  ),
                ] else ...[
                  // Step 3: Confirmed View
                  _ConfirmedSuccessView(stay: widget.stay),
                ],
              ],
            ),
          ),

          // Bottom Bar Action
          if (_currentStep < 3)
            Container(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              decoration: BoxDecoration(
                color: isDark ? VeyraTokens.darkCardSurface : Colors.white,
                boxShadow: VeyraTokens.shadowLG,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Grand Total', style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        grandTotalDisplay,
                        style: VeyraTokens.headlineMedium.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      if (_currentStep == 0) {
                        if (widget.bookingCtrl.checkIn == null || widget.bookingCtrl.checkOut == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select check-in and check-out dates.')),
                          );
                          return;
                        }
                        setState(() => _currentStep = 1);
                      } else if (_currentStep == 1) {
                        setState(() => _currentStep = 2);
                      } else if (_currentStep == 2) {
                        // Submit booking
                        await widget.bookingCtrl.submitBooking(widget.stay, 'guest');
                        setState(() => _currentStep = 3);
                      }
                    },
                    child: Text(
                      _currentStep == 0
                          ? 'Continue to Add-ons'
                          : _currentStep == 1
                              ? 'Continue to Payment'
                              : 'Confirm Reservation',
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

class _ConfirmedSuccessView extends StatelessWidget {
  final Stay stay;
  const _ConfirmedSuccessView({required this.stay});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final code = 'VYR-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 48, color: scheme.primary),
        ),
        const SizedBox(height: VeyraTokens.spaceMD),
        Text('Booking Confirmed!', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Reference: $code',
            style: VeyraTokens.labelLarge.copyWith(
              color: VeyraTokens.antiqueGold,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: VeyraTokens.spaceMD),
        Text(
          'Your sanctuary reservation at ${stay.title} has been logged. '
          'Your dedicated concierge has confirmed all bespoke add-ons.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: VeyraTokens.space2XL),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: scheme.primary,
          ),
          icon: const Icon(Icons.luggage_rounded),
          label: const Text('View in My Trips'),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            AppShell.switchTab(context, 3); // Jump to Trips!
          },
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
          : (bookingCtrl.checkOut ?? now.add(const Duration(days: 3))),
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
    final fmt = DateFormat('MMM dd, yyyy');
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context, true),
            child: Container(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check-in', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    bookingCtrl.checkIn != null ? fmt.format(bookingCtrl.checkIn!) : 'Select Date',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: VeyraTokens.spaceMD),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context, false),
            child: Container(
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check-out', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    bookingCtrl.checkOut != null ? fmt.format(bookingCtrl.checkOut!) : 'Select Date',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        const Icon(Icons.people_rounded),
        const SizedBox(width: VeyraTokens.spaceSM),
        Text('Adult Guests', style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded),
          onPressed: bookingCtrl.guests > 1
              ? () {
                  HapticFeedback.lightImpact();
                  bookingCtrl.setGuests(bookingCtrl.guests - 1);
                }
              : null,
        ),
        Text('${bookingCtrl.guests}', style: Theme.of(context).textTheme.headlineMedium),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded),
          onPressed: bookingCtrl.guests < stay.maxGuests
              ? () {
                  HapticFeedback.lightImpact();
                  bookingCtrl.setGuests(bookingCtrl.guests + 1);
                }
              : null,
        ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final dynamic price;
  const _PriceBreakdown({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('${price.nightlyPriceDisplay} × ${price.nights} nights'),
              const Spacer(),
              Text(price.nightlySubtotalDisplay),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Cleaning & Maintenance'),
              const Spacer(),
              Text(price.cleaningFeeDisplay),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('VIP Concierge & Service'),
              const Spacer(),
              Text(price.serviceFeeDisplay),
            ],
          ),
          if (price.discountCents > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Seasonal Member Discount (15%)', style: TextStyle(color: Colors.green)),
                const Spacer(),
                Text(price.discountDisplay, style: const TextStyle(color: Colors.green)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
