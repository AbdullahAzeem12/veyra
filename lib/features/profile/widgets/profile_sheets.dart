import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/scope/app_scope.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/widgets/fade_pop_item.dart';
import '../../../core/biometrics/biometric_service.dart';
import '../../../core/services/alert_service.dart';

// ── 1. Avatar & Profile Picker Sheet ──────────────────────────────────────────

class AvatarPickerSheet extends StatefulWidget {
  final UserProfileController profileCtrl;
  const AvatarPickerSheet({super.key, required this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    if (profileCtrl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(profileCtrl: profileCtrl),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  late final TextEditingController _nameCtrl;

  static const List<Map<String, String>> _avatars = [
    {
      'title': 'Alexander Wright',
      'role': 'Founder & Explorer',
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Sophia Laurent',
      'role': 'VIP Ambassador',
      'url':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Marcus Chen',
      'role': 'Global Nomad',
      'url':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Elena Rostova',
      'role': 'Private Collector',
      'url':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profileCtrl.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        VeyraTokens.spaceLG,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceLG,
        MediaQuery.of(context).viewInsets.bottom + VeyraTokens.spaceMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Text(
            'Personalize Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your VIP avatar or update your identity',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: VeyraTokens.spaceLG),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: VeyraTokens.spaceMD),
              itemBuilder: (context, i) {
                final item = _avatars[i];
                final isSelected = widget.profileCtrl.avatarUrl == item['url'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.profileCtrl.updateAvatar(item['url']!);
                    setState(() {});
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? scheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundImage: NetworkImage(item['url']!),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title']!.split(' ').first,
                        style: VeyraTokens.labelSmall.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected ? scheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceLG),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.profileCtrl.updateName(_nameCtrl.text);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully.')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
  }
}

// ── 2. Loyalty Rewards & Points Hub ───────────────────────────────────────────

class LoyaltyRewardsSheet extends StatelessWidget {
  final UserProfileController profileCtrl;
  const LoyaltyRewardsSheet({super.key, required this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    if (profileCtrl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoyaltyRewardsSheet(profileCtrl: profileCtrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: profileCtrl,
      builder: (context, _) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
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
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: VeyraTokens.antiqueGold,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veyra Club & Points',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: VeyraTokens.spaceMD,
                ),
                children: [
                  // VIP Black Card
                  Container(
                    padding: const EdgeInsets.all(VeyraTokens.spaceLG),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B2825),
                          const Color(0xFF0F1715),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
                      boxShadow: VeyraTokens.shadowLG,
                      border: Border.all(
                        color: VeyraTokens.antiqueGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'VEYRA PRIVILEGE',
                              style: VeyraTokens.labelSmall.copyWith(
                                color: VeyraTokens.antiqueGold,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.all_inclusive_rounded,
                              color: VeyraTokens.antiqueGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: VeyraTokens.spaceLG),
                        Text(
                          profileCtrl.tier,
                          style: VeyraTokens.headlineLarge.copyWith(
                            color: Colors.white,
                            fontFamily: VeyraTokens.fontDisplay,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MEMBER SINCE 2024 · VIP #8849-21',
                          style: VeyraTokens.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: VeyraTokens.spaceMD),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AVAILABLE REWARDS',
                                  style: VeyraTokens.labelSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  '${profileCtrl.points} PTS',
                                  style: VeyraTokens.headlineMedium.copyWith(
                                    color: VeyraTokens.antiqueGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'NEXT TIER',
                                  style: VeyraTokens.labelSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  'Royal Ambassador (5,000 pts)',
                                  style: VeyraTokens.labelSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (profileCtrl.points / 5000.0).clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation(
                              VeyraTokens.antiqueGold,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VeyraTokens.spaceLG),
                  Text(
                    'Exclusive Member Privileges',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: VeyraTokens.spaceSM),
                  _PrivilegeTile(
                    icon: Icons.wine_bar_rounded,
                    title: 'Complimentary Dom Pérignon',
                    subtitle: 'Chilled bottle placed in suite upon check-in',
                  ),
                  _PrivilegeTile(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Guaranteed 4:00 PM Late Check-out',
                    subtitle: 'Relax longer without extra charges',
                  ),
                  _PrivilegeTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Automatic Villa Upgrade',
                    subtitle: 'Next category room upgrade based on availability',
                  ),
                  _PrivilegeTile(
                    icon: Icons.support_agent_rounded,
                    title: '24/7 Dedicated Butler Service',
                    subtitle: 'Personal butler on call for private requests',
                  ),

                  const SizedBox(height: VeyraTokens.spaceLG),
                  Text(
                    'Redeem Points for Rewards',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: VeyraTokens.spaceSM),
                  _RewardRedeemCard(
                    title: '\$100 Luxury Stay Credit',
                    cost: 1000,
                    icon: Icons.card_giftcard_rounded,
                    canAfford: profileCtrl.points >= 1000,
                    onRedeem: () {
                      HapticFeedback.lightImpact();
                      final ok = profileCtrl.redeemReward(
                        '\$100 Luxury Stay Credit',
                        1000,
                      );
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voucher redeemed successfully! Check active vouchers.'),
                          ),
                        );
                      }
                    },
                  ),
                  _RewardRedeemCard(
                    title: 'Chauffeured Airport Transfer',
                    cost: 2000,
                    icon: Icons.directions_car_rounded,
                    canAfford: profileCtrl.points >= 2000,
                    onRedeem: () {
                      HapticFeedback.lightImpact();
                      final ok = profileCtrl.redeemReward(
                        'Chauffeured Airport Transfer',
                        2000,
                      );
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transfer voucher issued! Code added below.'),
                          ),
                        );
                      }
                    },
                  ),
                  _RewardRedeemCard(
                    title: 'Michelin 3-Star Tasting Menu for 2',
                    cost: 3500,
                    icon: Icons.restaurant_rounded,
                    canAfford: profileCtrl.points >= 3500,
                    onRedeem: () {
                      HapticFeedback.lightImpact();
                      final ok = profileCtrl.redeemReward(
                        'Michelin 3-Star Tasting Menu for 2',
                        3500,
                      );
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dining experience voucher active!'),
                          ),
                        );
                      }
                    },
                  ),

                  if (profileCtrl.vouchers.isNotEmpty) ...[
                    const SizedBox(height: VeyraTokens.spaceLG),
                    Text(
                      'Your Active Vouchers (${profileCtrl.vouchers.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: VeyraTokens.spaceSM),
                    ...profileCtrl.vouchers.map(
                      (v) => Container(
                        margin: const EdgeInsets.only(bottom: VeyraTokens.spaceSM),
                        padding: const EdgeInsets.all(VeyraTokens.spaceMD),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                          border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.confirmation_num_rounded, color: scheme.primary),
                            const SizedBox(width: VeyraTokens.spaceSM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.title, style: Theme.of(context).textTheme.titleSmall),
                                  Text('Code: ${v.code} · ${v.pointsSpent} pts',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                              ),
                              child: Text('READY',
                                  style: VeyraTokens.labelSmall.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: VeyraTokens.space2XL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivilegeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PrivilegeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: VeyraTokens.antiqueGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: VeyraTokens.antiqueGold, size: 16),
          ),
          const SizedBox(width: VeyraTokens.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRedeemCard extends StatelessWidget {
  final String title;
  final int cost;
  final IconData icon;
  final bool canAfford;
  final VoidCallback onRedeem;

  const _RewardRedeemCard({
    required this.title,
    required this.cost,
    required this.icon,
    required this.canAfford,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: VeyraTokens.spaceSM),
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 24),
          const SizedBox(width: VeyraTokens.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text('$cost Points',
                    style: TextStyle(
                      color: VeyraTokens.antiqueGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: canAfford ? onRedeem : null,
            child: Text(canAfford ? 'Redeem' : 'Locked'),
          ),
        ],
      ),
    );
  }
}

// ── 3. Currency Selector Sheet ────────────────────────────────────────────────

class CurrencySelectorSheet extends StatefulWidget {
  final CurrencyController? currencyCtrl;
  const CurrencySelectorSheet({super.key, this.currencyCtrl});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CurrencySelectorSheet(),
    );
  }

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyCtrl = widget.currencyCtrl ?? AppScope.currencyCtrlOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final allCurrencies = CurrencyController.supportedCurrencies;
    final filtered = _searchQuery.isEmpty
        ? allCurrencies
        : allCurrencies.where((c) {
            final q = _searchQuery.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q) ||
                c.symbol.toLowerCase().contains(q);
          }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: EdgeInsets.fromLTRB(
        VeyraTokens.spaceLG,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceLG,
        MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Currency',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Live conversion applied instantly across all stays & bookings',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search currency or symbol (USD, EUR, ¥)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Expanded(
            child: currencyCtrl == null
                ? const SizedBox.shrink()
                : ListenableBuilder(
                    listenable: currencyCtrl,
                    builder: (context, _) => ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final c = filtered[i];
                        final isSelected = currencyCtrl.code == c.code;
                        final sample = currencyCtrl.formatCents(58000);
                        return _InteractiveOptionTile(
                          isSelected: isSelected,
                          leading: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? VeyraTokens.darkCardSurface : const Color(0xFFF2EFEB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(c.flag, style: const TextStyle(fontSize: 22)),
                          ),
                          title: '${c.name} (${c.symbol})',
                          subtitle: '1 USD = ${c.rateFromUSD} ${c.code} · Sample: $sample',
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            currencyCtrl.setCurrency(c.code);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Currency updated to ${c.name} (${c.symbol})')),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 4. Language Selector Sheet ────────────────────────────────────────────────

class LanguageSelectorSheet extends StatelessWidget {
  final UserProfileController? profileCtrl;
  const LanguageSelectorSheet({super.key, this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageSelectorSheet(profileCtrl: profileCtrl),
    );
  }

  static const List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'flag': '🇺🇸', 'native': 'English (United States)'},
    {'name': 'English (UK)', 'flag': '🇬🇧', 'native': 'English (United Kingdom)'},
    {'name': 'Français', 'flag': '🇫🇷', 'native': 'Français (France)'},
    {'name': 'Deutsch', 'flag': '🇩🇪', 'native': 'Deutsch (Deutschland)'},
    {'name': 'Español', 'flag': '🇪🇸', 'native': 'Español (España)'},
    {'name': 'Italiano', 'flag': '🇮🇹', 'native': 'Italiano (Italia)'},
    {'name': '日本語', 'flag': '🇯🇵', 'native': '日本語 (日本)'},
    {'name': 'العربية', 'flag': '🇦🇪', 'native': 'العربية (الإمارات)'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeLanguage = profileCtrl?.language ?? 'English (US)';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: EdgeInsets.fromLTRB(
        VeyraTokens.spaceLG,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceLG,
        MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppTranslations.tr(context, 'select_language'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        shadows: VeyraTokens.headingShadows(isDark),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose your preferred luxury concierge language',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final l = _languages[i];
                final isSelected = l['name'] == activeLanguage;
                return FadePopItem(
                  index: i,
                  child: _InteractiveOptionTile(
                    isSelected: isSelected,
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? VeyraTokens.darkCardSurface : const Color(0xFFF2EFEB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                    ),
                    title: l['name']!,
                    subtitle: l['native']!,
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: VeyraTokens.deepEmerald,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          )
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      profileCtrl?.updateLanguage(l['name']!);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language set to ${l['name']}')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 5. Notification Preferences Hub ───────────────────────────────────────────

class NotificationsHubSheet extends StatelessWidget {
  final UserProfileController profileCtrl;
  const NotificationsHubSheet({super.key, required this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    if (profileCtrl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsHubSheet(profileCtrl: profileCtrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: profileCtrl,
      builder: (context, _) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(
          VeyraTokens.spaceLG,
          VeyraTokens.spaceMD,
          VeyraTokens.spaceLG,
          MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppTranslations.tr(context, 'notif_preferences'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          shadows: VeyraTokens.headingShadows(isDark),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Configure your VIP travel alerts & real-time updates',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Quiet Hours Card
                    FadePopItem(
                      index: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bedtime_rounded, color: Color(0xFF805AD5), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslations.tr(context, 'quiet_hours_title'),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    AppTranslations.tr(context, 'quiet_hours_sub'),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: profileCtrl.quietHoursEnabled,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                profileCtrl.toggleQuietHours(val);
                                VeyraAlertService.showLuxuryAlert(
                                  context,
                                  type: AlertType.quietHoursInfo,
                                  title: val ? 'Quiet Hours Activated' : 'Quiet Hours Disabled',
                                  message: val
                                      ? 'Non-critical notifications muted between 22:00 and 07:00.'
                                      : 'Standard alerts active 24/7.',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: VeyraTokens.spaceMD),
                    FadePopItem(
                      index: 1,
                      child: _NotificationTile(
                        icon: Icons.trending_down_rounded,
                        iconColor: const Color(0xFFDD6B20),
                        title: AppTranslations.tr(context, 'price_drop_alerts'),
                        subtitle: AppTranslations.tr(context, 'price_drop_sub'),
                        value: profileCtrl.priceDropAlerts,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.togglePriceDropAlerts(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.priceDrop,
                              title: 'Price Drop Alert',
                              message: 'Amalfi Cliffside Villa rate reduced by \$350/night!',
                              quietHoursActive: profileCtrl.quietHoursEnabled,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadePopItem(
                      index: 2,
                      child: _NotificationTile(
                        icon: Icons.calendar_month_rounded,
                        iconColor: VeyraTokens.deepEmerald,
                        title: AppTranslations.tr(context, 'booking_updates'),
                        subtitle: AppTranslations.tr(context, 'booking_updates_sub'),
                        value: profileCtrl.bookingUpdates,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.toggleBookingUpdates(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.bookingUpdate,
                              title: 'Booking Confirmed',
                              message: 'Private yacht chauffeur reservation confirmed for 14:00.',
                              quietHoursActive: profileCtrl.quietHoursEnabled,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadePopItem(
                      index: 3,
                      child: _NotificationTile(
                        icon: Icons.auto_awesome_rounded,
                        iconColor: VeyraTokens.antiqueGold,
                        title: AppTranslations.tr(context, 'concierge_offers'),
                        subtitle: AppTranslations.tr(context, 'concierge_offers_sub'),
                        value: profileCtrl.conciergeExclusives,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.toggleConciergeExclusives(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.conciergeOffer,
                              title: 'Black Tier Privilege',
                              message: 'Exclusive access to Necker Island private opening unlocked.',
                              quietHoursActive: profileCtrl.quietHoursEnabled,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadePopItem(
                      index: 4,
                      child: _NotificationTile(
                        icon: Icons.notifications_active_rounded,
                        iconColor: const Color(0xFF319795),
                        title: AppTranslations.tr(context, 'push_notifications'),
                        subtitle: AppTranslations.tr(context, 'push_notifications_sub'),
                        value: profileCtrl.pushNotifications,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.togglePushNotifications(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.conciergeOffer,
                              title: 'Push Notifications Enabled',
                              message: 'Your device is configured to receive instant VIP notifications.',
                              quietHoursActive: profileCtrl.quietHoursEnabled,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadePopItem(
                      index: 5,
                      child: _NotificationTile(
                        icon: Icons.mark_email_read_rounded,
                        iconColor: const Color(0xFF3182CE),
                        title: AppTranslations.tr(context, 'email_summaries'),
                        subtitle: AppTranslations.tr(context, 'email_summaries_sub'),
                        value: profileCtrl.emailNotifications,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.toggleEmailNotifications(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.bookingUpdate,
                              title: 'Email Dispatch Active',
                              message: 'Booking confirmations and receipts routed to ${profileCtrl.email}.',
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadePopItem(
                      index: 6,
                      child: _NotificationTile(
                        icon: Icons.sms_rounded,
                        iconColor: const Color(0xFF805AD5),
                        title: 'SMS Travel Alerts',
                        subtitle: 'Emergency gate changes and private chauffeur arrival alerts',
                        value: profileCtrl.smsNotifications,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          profileCtrl.toggleSmsNotifications(val);
                          if (val) {
                            VeyraAlertService.showLuxuryAlert(
                              context,
                              type: AlertType.security,
                              title: 'SMS Alerts Active',
                              message: 'Direct SMS channel opened for urgent itinerary changes.',
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: VeyraTokens.spaceMD),
                    FadePopItem(
                      index: 7,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                          ),
                        ),
                        icon: const Icon(Icons.notifications_active_rounded, size: 20),
                        label: Text(AppTranslations.tr(context, 'test_alert_btn')),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          VeyraAlertService.showLuxuryAlert(
                            context,
                            type: AlertType.conciergeOffer,
                            title: 'VIP Concierge Alert',
                            message: 'Helicopter transfer from Nice Côte d\'Azur is scheduled for 16:30.',
                            quietHoursActive: profileCtrl.quietHoursEnabled,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: VeyraTokens.spaceMD),
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

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
        boxShadow: VeyraTokens.shadowSM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── 6. Payment Methods & Wallet Manager ───────────────────────────────────────

class PaymentMethodsSheet extends StatefulWidget {
  final UserProfileController profileCtrl;
  const PaymentMethodsSheet({super.key, required this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    if (profileCtrl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentMethodsSheet(profileCtrl: profileCtrl),
    );
  }

  @override
  State<PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<PaymentMethodsSheet> {
  void _openAddCardDialog() {
    final numCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: widget.profileCtrl.name);
    String detectedBrand = 'Mastercard';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
          ),
          title: Row(
            children: [
              const Icon(Icons.add_card_rounded, color: VeyraTokens.deepEmerald),
              const SizedBox(width: 8),
              const Text('Add Payment Card'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Card Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A34), Color(0xFF101918)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeyraTokens.antiqueGold.withValues(alpha: 0.4)),
                    boxShadow: VeyraTokens.shadowMD,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.contactless_rounded, color: VeyraTokens.antiqueGold, size: 22),
                          Text(
                            detectedBrand.toUpperCase(),
                            style: VeyraTokens.labelSmall.copyWith(
                              color: VeyraTokens.antiqueGold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        numCtrl.text.isEmpty
                            ? '•••• •••• •••• ••••'
                            : numCtrl.text.padRight(16, '•'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CARDHOLDER', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8)),
                              Text(
                                nameCtrl.text.isEmpty ? 'ALEXANDER WRIGHT' : nameCtrl.text.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('EXPIRES', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8)),
                              Text(
                                expCtrl.text.isEmpty ? '12/28' : expCtrl.text,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setDialogState(() {
                      if (val.startsWith('4')) {
                        detectedBrand = 'Visa';
                      } else if (val.startsWith('3')) {
                        detectedBrand = 'Amex';
                      } else {
                        detectedBrand = 'Mastercard';
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '4000 1234 5678 9010',
                    prefixIcon: const Icon(Icons.credit_card_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expCtrl,
                        keyboardType: TextInputType.datetime,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cvvCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '•••',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final clean = numCtrl.text.replaceAll(' ', '');
                if (clean.length < 4) return;
                final last4 = clean.substring(clean.length - 4);
                widget.profileCtrl.addPaymentCard(
                  brand: detectedBrand,
                  last4: last4,
                  expiry: expCtrl.text.isNotEmpty ? expCtrl.text : '12/28',
                  cardholder: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'VIP TRAVELER',
                  setAsDefault: true,
                );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$detectedBrand •••• $last4 added & set as default!')),
                );
              },
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.profileCtrl,
      builder: (context, _) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: EdgeInsets.fromLTRB(
          VeyraTokens.spaceLG,
          VeyraTokens.spaceMD,
          VeyraTokens.spaceLG,
          MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment Methods',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: scheme.primary,
                  tooltip: 'Add Card',
                  onPressed: _openAddCardDialog,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Tap any card to set as your primary reservation billing method',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...widget.profileCtrl.paymentCards.map((card) => _CardTile(
                          card: card,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.profileCtrl.setDefaultCard(card.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${card.brand} •••• ${card.last4} set as default.')),
                            );
                          },
                          onSetDefault: () {
                            HapticFeedback.lightImpact();
                            widget.profileCtrl.setDefaultCard(card.id);
                          },
                          onDelete: () {
                            HapticFeedback.lightImpact();
                            widget.profileCtrl.removeCard(card.id);
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Another Card'),
              onPressed: _openAddCardDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatefulWidget {
  final PaymentCard card;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final isDefault = widget.card.isDefault;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          splashColor: scheme.primary.withValues(alpha: 0.12),
          child: Container(
            margin: const EdgeInsets.only(bottom: VeyraTokens.spaceSM),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? VeyraTokens.darkCardSurface : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              border: Border.all(
                color: isDefault ? scheme.primary : scheme.outline.withValues(alpha: 0.25),
                width: isDefault ? 1.8 : 1.0,
              ),
              boxShadow: isDefault
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : VeyraTokens.shadowSM,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (widget.card.brand.contains('Visa')
                            ? Colors.blue
                            : widget.card.brand.contains('Amex')
                                ? const Color(0xFF007BC1)
                                : VeyraTokens.antiqueGold)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.card.brand.contains('Visa')
                        ? Icons.payment_rounded
                        : Icons.credit_card_rounded,
                    color: widget.card.brand.contains('Visa')
                        ? Colors.blue
                        : VeyraTokens.antiqueGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${widget.card.brand} •••• ${widget.card.last4}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expires ${widget.card.expiry} · ${widget.card.cardholder}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (val) {
                    if (val == 'default') {
                      widget.onSetDefault();
                    } else if (val == 'delete') {
                      widget.onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as Default'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Remove Card', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 7. Security & Privacy Hub ─────────────────────────────────────────────────

class SecurityPrivacySheet extends StatefulWidget {
  final UserProfileController profileCtrl;
  const SecurityPrivacySheet({super.key, required this.profileCtrl});

  static void show(BuildContext context) {
    final profileCtrl = AppScope.profileCtrlOf(context);
    if (profileCtrl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SecurityPrivacySheet(profileCtrl: profileCtrl),
    );
  }

  @override
  State<SecurityPrivacySheet> createState() => _SecurityPrivacySheetState();
}

class _SecurityPrivacySheetState extends State<SecurityPrivacySheet> {
  bool _isTestingBiometric = false;
  String? _biometricTestResult;
  bool _isSuccess = false;
  String _hardwareStatus = 'Detecting biometric sensor...';

  @override
  void initState() {
    super.initState();
    _detectHardware();
  }

  Future<void> _detectHardware() async {
    final supported = await VeyraBiometricService.isBiometricsSupported();
    final types = await VeyraBiometricService.getAvailableBiometrics();
    if (!mounted) return;
    setState(() {
      if (!supported) {
        _hardwareStatus = 'Hardware: No biometric sensor detected on this device';
      } else if (types.isEmpty) {
        _hardwareStatus = 'Hardware: Biometric sensor ready (Fingerprint / Face ID)';
      } else {
        final names = types.map((t) => t.name.toUpperCase()).join(' & ');
        _hardwareStatus = 'Hardware: $names Sensor Active';
      }
    });
  }

  Future<void> _performRealBiometricAuth() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isTestingBiometric = true;
      _biometricTestResult = null;
    });

    final result = await VeyraBiometricService.authenticate(
      reason: 'Scan your biometric sensor (fingerprint/face) for VIP reservations and secure access.',
    );

    if (!mounted) return;
    setState(() {
      _isTestingBiometric = false;
      _isSuccess = result.success;
      _biometricTestResult = result.message;
    });

    if (result.success) {
      HapticFeedback.heavyImpact();
      VeyraAlertService.showLuxuryAlert(
        context,
        type: AlertType.security,
        title: 'Biometric Verified',
        message: 'VIP security clearance confirmed. Sensor operating normally.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.profileCtrl,
      builder: (context, _) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(
          VeyraTokens.spaceLG,
          VeyraTokens.spaceMD,
          VeyraTokens.spaceLG,
          MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppTranslations.tr(context, 'security_privacy'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          shadows: VeyraTokens.headingShadows(isDark),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Manage biometrics, 2FA, and authorized device sessions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadePopItem(
                      index: 0,
                      child: _NotificationTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: VeyraTokens.deepEmerald,
                        title: AppTranslations.tr(context, 'biometrics_title'),
                        subtitle: AppTranslations.tr(context, 'biometrics_sub'),
                        value: widget.profileCtrl.biometricsEnabled,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          widget.profileCtrl.toggleBiometrics(val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.profileCtrl.biometricsEnabled) ...[
                      FadePopItem(
                        index: 1,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(VeyraTokens.radiusSM),
                            border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sensors_rounded, size: 16, color: scheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _hardwareStatus,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadePopItem(
                        index: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: _isTestingBiometric
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.fingerprint_rounded, size: 18),
                            label: Text(_isTestingBiometric
                                ? 'Scanning Hardware Sensor...'
                                : AppTranslations.tr(context, 'test_biometric_btn')),
                            onPressed: _isTestingBiometric ? null : _performRealBiometricAuth,
                          ),
                        ),
                      ),
                      if (_biometricTestResult != null) ...[
                        const SizedBox(height: 6),
                        FadePopItem(
                          index: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (_isSuccess ? Colors.green : Colors.amber)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (_isSuccess ? Colors.green : Colors.amber)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                    size: 16,
                                    color: _isSuccess ? Colors.green : Colors.amber[800],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _biometricTestResult!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: _isSuccess ? Colors.green : Colors.amber[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                    FadePopItem(
                      index: 4,
                      child: _NotificationTile(
                        icon: Icons.security_rounded,
                        iconColor: const Color(0xFF3182CE),
                        title: AppTranslations.tr(context, 'two_factor_title'),
                        subtitle: AppTranslations.tr(context, 'two_factor_sub'),
                        value: widget.profileCtrl.twoFactorEnabled,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          widget.profileCtrl.toggleTwoFactor(val);
                        },
                      ),
                    ),
                    const SizedBox(height: VeyraTokens.spaceLG),
                    Row(
                      children: [
                        Text('Active Device Sessions', style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        if (widget.profileCtrl.sessions.length > 1)
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.profileCtrl.revokeOtherSessions();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('All other sessions revoked.')),
                              );
                            },
                            child: const Text('Revoke Others'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.profileCtrl.sessions.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
                            borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                            border: Border.all(
                              color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                s.deviceName.contains('MacBook')
                                    ? Icons.laptop_mac_rounded
                                    : s.deviceName.contains('iPad')
                                        ? Icons.tablet_mac_rounded
                                        : Icons.phone_iphone_rounded,
                                color: scheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          s.deviceName,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (s.isCurrent) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'THIS DEVICE',
                                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text('${s.location} · ${s.lastActive}',
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: VeyraTokens.spaceMD),
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

// ── Interactive Option Tile Helper ────────────────────────────────────────────

class _InteractiveOptionTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback onTap;

  const _InteractiveOptionTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_InteractiveOptionTile> createState() => _InteractiveOptionTileState();
}

class _InteractiveOptionTileState extends State<_InteractiveOptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: scheme.primary.withValues(alpha: 0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? scheme.primary.withValues(alpha: 0.08)
                  : (isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface),
              borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              border: Border.all(
                color: widget.isSelected
                    ? scheme.primary
                    : (isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder),
                width: widget.isSelected ? 1.6 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : VeyraTokens.shadowSM,
            ),
            child: Row(
              children: [
                widget.leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
                              color: widget.isSelected ? scheme.primary : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 8. 24/7 Dedicated AI Luxury Concierge Chat ───────────────────────────────

class ConciergeChatSheet extends StatefulWidget {
  const ConciergeChatSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConciergeChatSheet(),
    );
  }

  @override
  State<ConciergeChatSheet> createState() => _ConciergeChatSheetState();
}

class _ConciergeChatSheetState extends State<ConciergeChatSheet> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;
  Timer? _replyTimer;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Good day, Alexander. I am your 24/7 dedicated VIP Veyra Concierge. How may I elevate your travel experience today?',
      'time': 'Just now',
    },
  ];

  static const List<String> _quickPrompts = [
    '🚁 Book a private helicopter transfer',
    '🍾 Champagne in suite on arrival',
    '🛥️ Arrange private sunset yacht',
    '🍽️ Reserve Michelin-star private dining',
    '🕒 Request 4 PM late check-out',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add({
        'isUser': true,
        'text': text.trim(),
        'time': 'Just now',
      });
      _isTyping = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    // AI concierge response generator
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      String reply;
      final query = text.toLowerCase();
      if (query.contains('helicopter') || query.contains('transfer')) {
        reply =
            'Certainly, Alexander. I have initiated the private twin-engine helicopter transfer coordination for your upcoming stay. A chauffeur will escort you directly from the runway. Confirmation #HL-982.';
      } else if (query.contains('champagne') || query.contains('suite')) {
        reply =
            'Excellent choice. A chilled vintage bottle of Dom Pérignon along with artisan dark chocolates will be waiting in your master suite upon your arrival.';
      } else if (query.contains('yacht') || query.contains('sunset')) {
        reply =
            'Understood. I have held an exclusive 68ft Riva yacht charter for sunset cruising, complete with an onboard private chef and sommelier.';
      } else if (query.contains('michelin') || query.contains('dining') || query.contains('reserve')) {
        reply =
            'Reservation guaranteed. I have reserved the chef’s private table with custom bespoke wine pairing for you this evening.';
      } else if (query.contains('late') || query.contains('check-out') || query.contains('checkout')) {
        reply =
            'As an esteemed Black Tier member, your 4:00 PM late check-out is pre-approved and logged with property management. Relax and enjoy your stay.';
      } else {
        reply =
            'My pleasure, Alexander. Your request has been personally registered with our head butler and local destination liaison. Is there anything else you require?';
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text': reply,
          'time': 'Just now',
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

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
                CircleAvatar(
                  backgroundColor: VeyraTokens.deepEmerald,
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white),
                ),
                const SizedBox(width: VeyraTokens.spaceSM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veyra VIP Concierge', style: Theme.of(context).textTheme.titleSmall),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Active 24/7 · Dedicated Agent',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                      ],
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

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(VeyraTokens.spaceMD),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: VeyraTokens.spaceSM),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? scheme.primary
                          : isDark
                              ? VeyraTokens.darkCardSurface
                              : const Color(0xFFF0EDE6),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      m['text'] as String,
                      style: TextStyle(
                        color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text('Concierge is preparing response...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ),

          // Quick Prompt Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: VeyraTokens.spaceMD),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = _quickPrompts[i];
                return ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage(p),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Message Input Field
          Padding(
            padding: EdgeInsets.fromLTRB(
              VeyraTokens.spaceMD,
              0,
              VeyraTokens.spaceMD,
              MediaQuery.of(context).viewInsets.bottom + VeyraTokens.spaceMD,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type your VIP travel request...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: () => _sendMessage(_msgCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 9. About Veyra Luxury Modal ───────────────────────────────────────────────

class AboutVeyraSheet extends StatelessWidget {
  const AboutVeyraSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AboutVeyraSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        VeyraTokens.spaceLG,
        VeyraTokens.spaceMD,
        VeyraTokens.spaceLG,
        MediaQuery.of(context).padding.bottom + VeyraTokens.spaceMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.travel_explore_rounded, color: scheme.primary, size: 28),
                ),
                const SizedBox(width: VeyraTokens.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Veyra Luxury Explorer', style: Theme.of(context).textTheme.headlineMedium),
                      Text('Version 1.2.0 (Living Architecture Release)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            const Text(
              'Veyra is an avant-garde luxury stay exploration platform engineered with '
              'reactive living intelligence, 60fps micro-transitions, real-time currency calculation, '
              'multi-layered 3D elevation, and dedicated 24/7 VIP concierge services.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: VeyraTokens.spaceMD),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_in_talk_rounded),
              title: const Text('VIP Concierge Direct Line'),
              subtitle: const Text('+1 (800) 849-VEYRA · concierge@veyra.travel'),
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.verified_user_rounded),
              title: const Text('Privacy & Security Protocol'),
              subtitle: const Text('End-to-end encrypted biometric booking clearance'),
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(height: VeyraTokens.spaceLG),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
