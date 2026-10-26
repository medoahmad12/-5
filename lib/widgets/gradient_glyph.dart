import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/settings_service.dart';
import 'package:provider/provider.dart';

/// A playful pseudo-3D letter/number built from layered text:
/// dark extrusion layers + gradient face + soft shadow, with a springy
/// bounce when tapped. Crisp on every screen size (vector text, not images).
class GradientGlyph extends StatefulWidget {
  final String glyph;
  final double size;
  final List<Color> colors;
  final VoidCallback? onTap;
  final bool extrude;

  const GradientGlyph({
    super.key,
    required this.glyph,
    required this.size,
    this.colors = const [Color(0xFFFFE29A), AppColors.orange],
    this.onTap,
    this.extrude = true,
  });

  @override
  State<GradientGlyph> createState() => _GradientGlyphState();
}

class _GradientGlyphState extends State<GradientGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.86), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.86, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounce.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        context.watch<SettingsService>().reduceMotion;
    final base = TextStyle(
      fontSize: widget.size,
      height: 1.1,
      fontWeight: FontWeight.w800,
      fontFamily: 'BalooBhaijaan2',
    );

    final face = ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: widget.colors,
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text(widget.glyph,
          style: base.copyWith(color: Colors.white),
          textDirection: TextDirection.ltr),
    );

    Widget glyph = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (widget.extrude)
          ...List.generate(5, (i) {
            final t = i / 5;
            return Positioned(
              left: i * widget.size * 0.018,
              top: i * widget.size * 0.022,
              child: Text(
                widget.glyph,
                style: base.copyWith(
                  color: Color.lerp(
                      darken(widget.colors.last, 0.55), Colors.black, t),
                ),
                textDirection: TextDirection.ltr,
              ),
            );
          }),
        Text(
          widget.glyph,
          style: base.copyWith(
            color: Colors.transparent,
            shadows: [
              Shadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: widget.size * 0.08,
                  offset: Offset(0, widget.size * 0.04)),
            ],
          ),
          textDirection: TextDirection.ltr,
        ),
        face,
        // Glossy highlight
        Positioned(
          top: widget.size * 0.06,
          child: ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.85),
                Colors.white.withOpacity(0.0),
              ],
            ).createShader(rect),
            blendMode: BlendMode.srcIn,
            child: Text(widget.glyph,
                style: base.copyWith(
                    color: Colors.white,
                    fontSize: widget.size * 0.985),
                textDirection: TextDirection.ltr),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, child) => Transform.scale(
          scale: (reduceMotion ? 1.0 : _scale.value) * (_pressed ? 0.95 : 1.0),
          child: child,
        ),
        child: SizedBox(
          width: widget.size * 1.25,
          height: widget.size * 1.3,
          child: Center(child: glyph),
        ),
      ),
    );
  }
}

Color darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}
