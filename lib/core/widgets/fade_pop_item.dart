import 'dart:async';
import 'package:flutter/material.dart';

/// Wraps any list/grid item with a smooth staggered fade-in and pop-in scale animation
/// with high opacity and spring curve transitions.
class FadePopItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double initialScale;
  final Curve curve;

  const FadePopItem({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 320),
    this.initialScale = 0.92,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadePopItem> createState() => _FadePopItemState();
}

class _FadePopItemState extends State<FadePopItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnim = Tween<double>(begin: widget.initialScale, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );

    // Stagger delay based on index capped at 320ms
    final delayMs = (widget.index * 40).clamp(0, 320);
    if (delayMs <= 0) {
      _ctrl.forward();
    } else {
      _staggerTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted) {
          _ctrl.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: widget.child,
        ),
      ),
    );
  }
}
