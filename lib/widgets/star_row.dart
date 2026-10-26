import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Row of up-to-3 earned stars (gold = earned, pale = missing).
class StarRow extends StatelessWidget {
  final int stars; // 0..3
  final double size;
  const StarRow({super.key, required this.stars, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final earned = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            earned ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: earned ? AppColors.star : AppColors.lockedGray,
          ),
        );
      }),
    );
  }
}

/// Big glowing star chip used in HUDs.
class StarChip extends StatelessWidget {
  final int count;
  final double fontSize;
  const StarChip({super.key, required this.count, this.fontSize = 17});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.star, size: 22),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
