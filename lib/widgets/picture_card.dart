import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/size_config.dart';

/// White rounded "flashcard" showing an object picture with optional label.
/// Used for words, game options and drag targets.
class PictureCard extends StatefulWidget {
  final String objectName; // file name under assets/images/objects
  final String? label;
  final double size;
  final VoidCallback? onTap;
  final Color? borderColor;

  const PictureCard({
    super.key,
    required this.objectName,
    this.label,
    this.size = 110,
    this.onTap,
    this.borderColor,
  });

  @override
  State<PictureCard> createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          width: widget.size,
          padding: EdgeInsets.all(8.sp.clamp(6.0, 12.0)),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.borderColor ?? Colors.white,
              width: widget.borderColor == null ? 0 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Image.asset(
                  AppAssets.object(widget.objectName),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_rounded,
                    color: AppColors.lockedGray,
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp.clamp(12.0, 20.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
