import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () => context.read<ThemeController>().toggle(brightness),
    );
  }
}
