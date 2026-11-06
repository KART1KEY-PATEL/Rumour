import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'pressable_scale.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = enabled && !isLoading && onPressed != null;
    return PressableScale(
      enabled: active,
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? colors.accent : colors.accent.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: colors.onAccent,
                    ),
                  )
                : Text(label, style: AppTextStyles.buttonLabel(colors)),
          ),
        ),
      ),
    );
  }
}
