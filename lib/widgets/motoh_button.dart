import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MotohButton extends StatelessWidget {
  const MotohButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = MotohButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final MotohButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final child = loading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == MotohButtonVariant.primary ? Colors.white : AppColors.primary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22),
                const SizedBox(width: 10),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case MotohButtonVariant.primary:
        return ElevatedButton(onPressed: disabled ? null : onPressed, child: child);
      case MotohButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            foregroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: child,
        );
      case MotohButtonVariant.outline:
        return OutlinedButton(onPressed: disabled ? null : onPressed, child: child);
    }
  }
}

enum MotohButtonVariant { primary, secondary, outline }
