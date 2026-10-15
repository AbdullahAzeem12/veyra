import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

enum AlertType { priceDrop, bookingUpdate, conciergeOffer, quietHoursInfo, security }

class VeyraAlertItem {
  final String title;
  final String message;
  final AlertType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  const VeyraAlertItem({
    required this.title,
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });
}

/// Dispatches real-time VIP alerts and floating notification HUDs based on user choices.
class VeyraAlertService {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void cancelDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
  }

  static void dismissAlert() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      try {
        _currentEntry!.remove();
      } catch (_) {}
      _currentEntry = null;
    }
  }

  static void showLuxuryAlert(
    BuildContext context, {
    required String title,
    required String message,
    required AlertType type,
    String? actionLabel,
    VoidCallback? onAction,
    bool quietHoursActive = false,
  }) {
    HapticFeedback.heavyImpact();

    // If quiet hours are active and not security, prepend quiet hours indicator
    final effectiveTitle = quietHoursActive ? '🌙 $title (Muted in Quiet Hours)' : title;

    dismissAlert();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => _LuxuryAlertBanner(
        title: effectiveTitle,
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          dismissAlert();
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(const Duration(seconds: 4), () {
      dismissAlert();
    });
  }
}

class _LuxuryAlertBanner extends StatefulWidget {
  final String title;
  final String message;
  final AlertType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _LuxuryAlertBanner({
    required this.title,
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_LuxuryAlertBanner> createState() => _LuxuryAlertBannerState();
}

class _LuxuryAlertBannerState extends State<_LuxuryAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    VeyraAlertService.cancelDismissTimer();
    _animCtrl.dispose();
    super.dispose();
  }

  Color _getBadgeColor() {
    switch (widget.type) {
      case AlertType.priceDrop:
        return const Color(0xFFE53E3E);
      case AlertType.bookingUpdate:
        return const Color(0xFF3182CE);
      case AlertType.conciergeOffer:
        return VeyraTokens.antiqueGold;
      case AlertType.quietHoursInfo:
        return const Color(0xFF805AD5);
      case AlertType.security:
        return VeyraTokens.deepEmerald;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AlertType.priceDrop:
        return Icons.trending_down_rounded;
      case AlertType.bookingUpdate:
        return Icons.event_available_rounded;
      case AlertType.conciergeOffer:
        return Icons.auto_awesome_rounded;
      case AlertType.quietHoursInfo:
        return Icons.bedtime_rounded;
      case AlertType.security:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = _getBadgeColor();

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162522) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(VeyraTokens.radiusLG),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_getIcon(), color: badgeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: badgeColor,
                        ),
                        onPressed: () {
                          widget.onDismiss();
                          widget.onAction?.call();
                        },
                        child: Text(widget.actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: isDark ? Colors.white54 : Colors.black45,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onDismiss,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
