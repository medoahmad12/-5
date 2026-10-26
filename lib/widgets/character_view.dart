import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../services/settings_service.dart';

/// A cartoon guide character with a soft idle bob (disabled when the parent
/// enables "reduce motion"), an optional speech bubble, and optional flip.
class CharacterView extends StatefulWidget {
  final String charId; // lulu / toto / bobo / foufo
  final String pose; // idle / point / cheer
  final double size;
  final bool flip;
  final String? bubble;
  final VoidCallback? onTap;
  final bool bob;

  const CharacterView({
    super.key,
    required this.charId,
    this.pose = 'idle',
    this.size = 120,
    this.flip = false,
    this.bubble,
    this.onTap,
    this.bob = true,
  });

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100 + Random().nextInt(300)),
    );
    if (widget.bob) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        context.watch<SettingsService>().reduceMotion;
    final path = AppAssets.char(widget.charId, widget.pose);

    Widget img = Image.asset(
      path,
      width: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => Icon(
        Icons.pets,
        size: widget.size * 0.7,
        color: AppColors.sun,
      ),
    );

    if (widget.flip) {
      img = Transform.flip(flipX: true, child: img);
    }

    final body = reduceMotion
        ? img
        : AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final dy = sin(_ctrl.value * pi) * widget.size * 0.035;
              final rot = sin(_ctrl.value * pi) * 0.02;
              return Transform.translate(
                offset: Offset(0, -dy),
                child: Transform.rotate(angle: rot, child: child),
              );
            },
            child: img,
          );

    if (widget.bubble == null) {
      return GestureDetector(onTap: widget.onTap, child: body);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpeechBubble(text: widget.bubble!),
          const SizedBox(height: 6),
          body,
        ],
      ),
    );
  }
}

/// Rounded speech bubble with a little tail — always RTL-aware via Ambient
/// directionality so Arabic and English both render naturally.
class SpeechBubble extends StatelessWidget {
  final String text;
  final Color color;
  const SpeechBubble({
    super.key,
    required this.text,
    this.color = AppColors.paper,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubbleTailPainter(
          color: color, tailOnRight: Directionality.of(context) == TextDirection.rtl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 260),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool tailOnRight;
  _BubbleTailPainter({required this.color, required this.tailOnRight});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(18));
    final paint = Paint()..color = color;
    canvas.drawRRect(r, paint);

    final tailX = tailOnRight ? size.width * 0.78 : size.width * 0.22;
    final path = Path()
      ..moveTo(tailX - 12, size.height - 14)
      ..lineTo(tailX + 12, size.height - 14)
      ..lineTo(tailX + 3, size.height + 8)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) =>
      old.color != color || old.tailOnRight != tailOnRight;
}
