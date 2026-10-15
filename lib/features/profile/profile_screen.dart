import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/fade_pop_item.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/localization/app_translations.dart';
import '../../app.dart';
import 'widgets/profile_sheets.dart';

/// Screen F — Profile & Preferences
/// Fully living profile screen with real state, wallet, rewards, currency exchange,
/// notification hub, 24/7 AI VIP concierge, and security preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = AppScope.themeCtrlOf(context);
    final savedCtrl = AppScope.savedCtrlOf(context);
    final bookingCtrl = AppScope.bookingCtrlOf(context);
    final profileCtrl = AppScope.profileCtrlOf(context);
    final currencyCtrl = AppScope.currencyCtrlOf(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(AppTranslations.tr(context, 'nav_profile')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
            )
          : null,
      body: SafeArea(
        top: !canPop,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= VeyraTokens.mediumBreakpoint;
            return isWide
                ? _WideProfileLayout(
                    themeCtrl: themeCtrl,
                    profileCtrl: profileCtrl,
                    currencyCtrl: currencyCtrl,
                    savedCount: savedCtrl?.savedIds.length ?? 0,
                    tripCount: bookingCtrl?.bookings.length ?? 0,
                  )
                : _CompactProfileLayout(
                    themeCtrl: themeCtrl,
                    profileCtrl: profileCtrl,
                    currencyCtrl: currencyCtrl,
                    savedCount: savedCtrl?.savedIds.length ?? 0,
                    tripCount: bookingCtrl?.bookings.length ?? 0,
                  );
          },
        ),
      ),
    );
  }
}

// ── Compact (Phone) Layout ────────────────────────────────────────────────────

class _CompactProfileLayout extends StatelessWidget {
  final ThemeController? themeCtrl;
  final UserProfileController? profileCtrl;
  final CurrencyController? currencyCtrl;
  final int savedCount;
  final int tripCount;

  const _CompactProfileLayout({
    required this.themeCtrl,
    required this.profileCtrl,
    required this.currencyCtrl,
    required this.savedCount,
    required this.tripCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      children: [
        FadePopItem(index: 0, child: _ProfileHeader(profileCtrl: profileCtrl)),
        const SizedBox(height: VeyraTokens.spaceLG),
        FadePopItem(
          index: 1,
          child: _StatsRow(
            savedCount: savedCount,
            tripCount: tripCount,
            profileCtrl: profileCtrl,
          ),
        ),
        const SizedBox(height: VeyraTokens.spaceXL),
        if (themeCtrl != null) ...[
          FadePopItem(index: 2, child: _AppearanceSection(themeCtrl: themeCtrl!)),
          const SizedBox(height: VeyraTokens.spaceLG),
        ],
        FadePopItem(
          index: 3,
          child: _PreferencesSection(currencyCtrl: currencyCtrl, profileCtrl: profileCtrl),
        ),
        const SizedBox(height: VeyraTokens.spaceLG),
        FadePopItem(
          index: 4,
          child: _AccountSection(profileCtrl: profileCtrl),
        ),
        const SizedBox(height: VeyraTokens.spaceLG),
        FadePopItem(index: 5, child: const _SignOutButton()),
        const SizedBox(height: VeyraTokens.space2XL),
      ],
    );
  }
}

// ── Wide (Tablet/Desktop) Layout ──────────────────────────────────────────────

class _WideProfileLayout extends StatelessWidget {
  final ThemeController? themeCtrl;
  final UserProfileController? profileCtrl;
  final CurrencyController? currencyCtrl;
  final int savedCount;
  final int tripCount;

  const _WideProfileLayout({
    required this.themeCtrl,
    required this.profileCtrl,
    required this.currencyCtrl,
    required this.savedCount,
    required this.tripCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VeyraTokens.spaceXL),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    FadePopItem(index: 0, child: _ProfileHeader(profileCtrl: profileCtrl)),
                    const SizedBox(height: VeyraTokens.spaceLG),
                    FadePopItem(
                      index: 1,
                      child: _StatsRow(
                        savedCount: savedCount,
                        tripCount: tripCount,
                        profileCtrl: profileCtrl,
                      ),
                    ),
                    const SizedBox(height: VeyraTokens.spaceXL),
                    FadePopItem(index: 2, child: const _SignOutButton()),
                  ],
                ),
              ),
              const SizedBox(width: VeyraTokens.space2XL),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    if (themeCtrl != null) ...[
                      FadePopItem(index: 3, child: _AppearanceSection(themeCtrl: themeCtrl!)),
                      const SizedBox(height: VeyraTokens.spaceLG),
                    ],
                    FadePopItem(
                      index: 4,
                      child: _PreferencesSection(currencyCtrl: currencyCtrl, profileCtrl: profileCtrl),
                    ),
                    const SizedBox(height: VeyraTokens.spaceLG),
                    FadePopItem(
                      index: 5,
                      child: _AccountSection(profileCtrl: profileCtrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfileController? profileCtrl;
  const _ProfileHeader({this.profileCtrl});

  void _showEditNameDialog(BuildContext context, UserProfileController? profileCtrl) {
    if (profileCtrl == null) return;
    final textCtrl = TextEditingController(text: profileCtrl.name);
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: scheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppTranslations.tr(ctx, 'edit_name'),
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        shadows: VeyraTokens.headingShadows(isDark),
                      ),
                ),
              ),
            ],
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppTranslations.tr(ctx, 'cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.primary),
              onPressed: () {
                final newName = textCtrl.text.trim();
                if (newName.isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  profileCtrl.updateName(newName);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTranslations.tr(context, 'name_updated')),
                    ),
                  );
                }
              },
              child: Text(AppTranslations.tr(ctx, 'save')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = profileCtrl?.name ?? 'Alexander Wright';
    final email = profileCtrl?.email ?? 'alexander.wright@veyra.travel';
    final avatarUrl = profileCtrl?.avatarUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

    return Container(
      padding: const EdgeInsets.all(VeyraTokens.spaceLG),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        boxShadow: VeyraTokens.shadowMD,
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _AvatarBadge(
            scheme: scheme,
            avatarUrl: avatarUrl,
            onTap: () {
              HapticFeedback.lightImpact();
              AvatarPickerSheet.show(context);
            },
          ),
          const SizedBox(height: VeyraTokens.spaceMD),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      shadows: VeyraTokens.headingShadows(isDark),
                    ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 22),
                tooltip: 'Edit Name',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showEditNameDialog(context, profileCtrl);
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          _MembershipBadge(
            scheme: scheme,
            tier: profileCtrl?.tier ?? 'Veyra Black Tier',
            onTap: () {
              HapticFeedback.lightImpact();
              LoyaltyRewardsSheet.show(context);
            },
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final ColorScheme scheme;
  final String avatarUrl;
  final VoidCallback onTap;

  const _AvatarBadge({
    required this.scheme,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [scheme.primary, VeyraTokens.antiqueGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: VeyraTokens.shadowMD,
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundImage: avatarImageProvider(avatarUrl),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  final ColorScheme scheme;
  final String tier;
  final VoidCallback onTap;

  const _MembershipBadge({
    required this.scheme,
    required this.tier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VeyraTokens.spaceMD,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: VeyraTokens.antiqueGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          border: Border.all(
            color: VeyraTokens.antiqueGold.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 16,
              color: VeyraTokens.antiqueGold,
            ),
            const SizedBox(width: 4),
            Text(
              tier,
              style: VeyraTokens.labelSmall.copyWith(
                color: VeyraTokens.antiqueGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: VeyraTokens.antiqueGold,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int savedCount;
  final int tripCount;
  final UserProfileController? profileCtrl;

  const _StatsRow({
    required this.savedCount,
    required this.tripCount,
    this.profileCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final points = profileCtrl?.points ?? 4250;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Saved Stays',
            value: '$savedCount',
            icon: Icons.favorite_rounded,
            iconColor: Colors.redAccent,
            onTap: () {
              HapticFeedback.lightImpact();
              AppShell.switchTab(context, 2); // Jump to Saved
            },
          ),
        ),
        const SizedBox(width: VeyraTokens.spaceMD),
        Expanded(
          child: _StatCard(
            label: 'Trips Booked',
            value: '$tripCount',
            icon: Icons.flight_takeoff_rounded,
            iconColor: VeyraTokens.deepEmerald,
            onTap: () {
              HapticFeedback.lightImpact();
              AppShell.switchTab(context, 3); // Jump to Trips
            },
          ),
        ),
        const SizedBox(width: VeyraTokens.spaceMD),
        Expanded(
          child: _StatCard(
            label: 'Veyra Points',
            value: '$points',
            icon: Icons.stars_rounded,
            iconColor: VeyraTokens.antiqueGold,
            onTap: () {
              HapticFeedback.lightImpact();
              LoyaltyRewardsSheet.show(context);
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: VeyraTokens.spaceMD,
              horizontal: VeyraTokens.spaceSM,
            ),
            decoration: BoxDecoration(
              color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
              borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
              border: Border.all(
                color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
              ),
              boxShadow: VeyraTokens.shadowSM,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
                ),
                const SizedBox(height: VeyraTokens.spaceXS),
                Text(
                  widget.value,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Appearance Section (Theme Mode & 3D Depth Toggle) ─────────────────────────

class _AppearanceSection extends StatelessWidget {
  final ThemeController themeCtrl;
  const _AppearanceSection({required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeCtrl,
      builder: (context, _) => _SettingsCard(
        title: AppTranslations.tr(context, 'theme_preference'),
        children: [
          _ThemeModeRow(themeCtrl: themeCtrl),
          const Divider(),
          _VisualDepthToggle(themeCtrl: themeCtrl),
        ],
      ),
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  final ThemeController themeCtrl;
  const _ThemeModeRow({required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VeyraTokens.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.tr(context, 'theme_preference'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemePreference>(
              emptySelectionAllowed: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  icon: const Icon(Icons.brightness_auto_rounded, size: 16),
                  label: Text(AppTranslations.tr(context, 'system'), maxLines: 1, softWrap: false),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  icon: const Icon(Icons.light_mode_rounded, size: 16),
                  label: Text(AppTranslations.tr(context, 'light'), maxLines: 1, softWrap: false),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  icon: const Icon(Icons.dark_mode_rounded, size: 16),
                  label: Text(AppTranslations.tr(context, 'dark'), maxLines: 1, softWrap: false),
                ),
              ],
              selected: {themeCtrl.themePreference},
              onSelectionChanged: (val) {
                if (val.isNotEmpty) {
                  HapticFeedback.lightImpact();
                  themeCtrl.setThemePreference(val.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualDepthToggle extends StatelessWidget {
  final ThemeController themeCtrl;
  const _VisualDepthToggle({required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(Icons.layers_rounded, color: scheme.primary, size: 22),
          const SizedBox(width: VeyraTokens.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.tr(context, 'premium_depth'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  AppTranslations.tr(context, 'premium_depth_sub'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      value: themeCtrl.premiumDepthEnabled,
      onChanged: (val) {
        HapticFeedback.lightImpact();
        themeCtrl.setPremiumDepth(val);
      },
    );
  }
}

// ── Preferences Section ───────────────────────────────────────────────────────

class _PreferencesSection extends StatelessWidget {
  final CurrencyController? currencyCtrl;
  final UserProfileController? profileCtrl;
  const _PreferencesSection({this.currencyCtrl, this.profileCtrl});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        if (currencyCtrl != null) currencyCtrl!,
        if (profileCtrl != null) profileCtrl!,
      ]),
      builder: (context, _) {
        final curr = currencyCtrl?.current;
        final currencySubtitle = curr != null
            ? '${curr.code} (${curr.symbol}) · 1 USD = ${curr.rateFromUSD} ${curr.code}'
            : 'USD (\$)';
        final languageSubtitle = profileCtrl?.language ?? 'English (US)';
        final notifSubtitle = profileCtrl?.quietHoursEnabled == true
            ? 'VIP Quiet Hours Active (22:00 - 07:00)'
            : 'VIP alerts & booking updates enabled';

        return _SettingsCard(
          title: AppTranslations.tr(context, 'preferences'),
          children: [
            _SettingsTile(
              icon: Icons.attach_money_rounded,
              title: AppTranslations.tr(context, 'currency'),
              subtitle: currencySubtitle,
              onTap: () {
                CurrencySelectorSheet.show(context);
              },
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: AppTranslations.tr(context, 'language'),
              subtitle: languageSubtitle,
              onTap: () {
                LanguageSelectorSheet.show(context);
              },
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: AppTranslations.tr(context, 'notifications'),
              subtitle: notifSubtitle,
              onTap: () {
                NotificationsHubSheet.show(context);
              },
            ),
          ],
        );
      },
    );
  }
}

// ── Account & Support Section ─────────────────────────────────────────────────

class _AccountSection extends StatelessWidget {
  final UserProfileController? profileCtrl;
  const _AccountSection({this.profileCtrl});

  @override
  Widget build(BuildContext context) {
    final listenable = profileCtrl ?? ChangeNotifier();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final defaultCard = profileCtrl?.defaultCard;
        final cardSubtitle = defaultCard != null
            ? '•••• ${defaultCard.last4} (${defaultCard.brand})'
            : '•••• 4821 (Mastercard)';
        final securitySubtitle = profileCtrl?.biometricsEnabled == true
            ? 'Biometrics Active · 2FA Ready'
            : 'Standard Security';

        return _SettingsCard(
          title: AppTranslations.tr(context, 'account_support'),
          children: [
            _SettingsTile(
              icon: Icons.credit_card_rounded,
              title: AppTranslations.tr(context, 'payment_methods'),
              subtitle: cardSubtitle,
              onTap: () {
                PaymentMethodsSheet.show(context);
              },
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.security_rounded,
              title: AppTranslations.tr(context, 'security_privacy'),
              subtitle: securitySubtitle,
              onTap: () {
                SecurityPrivacySheet.show(context);
              },
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.support_agent_rounded,
              title: AppTranslations.tr(context, 'concierge_support'),
              subtitle: '24/7 dedicated travel concierge',
              onTap: () {
                ConciergeChatSheet.show(context);
              },
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppTranslations.tr(context, 'about_veyra'),
              subtitle: 'v1.2.0 (Living Architecture Release)',
              onTap: () {
                AboutVeyraSheet.show(context);
              },
            ),
          ],
        );
      },
    );
  }
}

// ── Shared Settings Container ─────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(VeyraTokens.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightSurface,
        borderRadius: BorderRadius.circular(VeyraTokens.radiusXL),
        border: Border.all(
          color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
        ),
        boxShadow: VeyraTokens.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  shadows: VeyraTokens.headingShadows(isDark),
                ),
          ),
          const SizedBox(height: VeyraTokens.spaceSM),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            splashColor: scheme.primary.withValues(alpha: 0.12),
            highlightColor: scheme.primary.withValues(alpha: 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: _isHovered
                    ? scheme.primary.withValues(alpha: isDark ? 0.08 : 0.04)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.16),
                          scheme.primary.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(widget.icon, color: scheme.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
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
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    offset: _isPressed || _isHovered ? const Offset(0.08, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: _isHovered
                          ? scheme.primary
                          : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign Out Button ───────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.error,
        side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        ),
      ),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: Text(AppTranslations.tr(context, 'sign_out')),
      onPressed: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text('${AppTranslations.tr(context, 'sign_out')}?'),
            content: const Text(
              'Your offline cached stays, saved boards, and concierge sessions will remain securely encrypted on this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(AppTranslations.tr(context, 'cancel')),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: scheme.error),
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully.')),
                  );
                },
                child: Text(AppTranslations.tr(context, 'sign_out')),
              ),
            ],
          ),
        );
      },
    );
  }
}
