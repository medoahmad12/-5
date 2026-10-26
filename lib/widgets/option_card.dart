import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Big tappable answer card with feedback states:
/// normal / correct (green glow) / wrong (warm shake, never scary).
class OptionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final OptionState state;
  final double width;
  final double height;
  final Color tint;

  const OptionCard({
    super.key,
    required this.child,
    this.onTap,
    this.state = OptionState.normal,
    this.width = 120,
    this.height = 130,
    this.tint = Colors.white,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

enum OptionState { normal, correct, wrong, hint }

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
  }

  @override
  void didUpdateWidget(covariant OptionCard old) {
    super.didUpdateWidget(old);
    if (widget.state == OptionState.wrong &&
        old.state != OptionState.wrong) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (widget.state) {
      OptionState.correct => AppColors.success,
      OptionState.wrong => AppColors.gentleError,
      OptionState.hint => AppColors.sun,
      OptionState.normal => Colors.white,
    };

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = t == 0 ? 0.0 : sin(t * pi * 3) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.tint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: (widget.state == OptionState.correct
                        ? AppColors.success
                        : Colors.brown)
                    .withOpacity(widget.state == OptionState.correct ? 0.5 : 0.18),
                blurRadius: widget.state == OptionState.correct ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
