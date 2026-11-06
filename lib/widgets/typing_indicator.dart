
import 'package:flutter/material.dart';

import '../app/theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, required this.names});

  final List<String> names;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label {
    if (widget.names.isEmpty) return '';

    if (widget.names.length == 1) {
      return '${widget.names.first} is typing';
    }

    if (widget.names.length == 2) {
      return '${widget.names[0]} and ${widget.names[1]} are typing';
    }

    return '${widget.names.length} people are typing';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.bottomCenter,
      child: widget.names.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label,
                    style: AppTextStyles.timestamp(
                      colors,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 22,
                    height: 10,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (i) {
                            final t =
                                (_controller.value - i * 0.2) % 1.0;

                            final bounce = t < 0.5
                                ? t * 2
                                : (1 - t) * 2;

                            return Transform.translate(
                              offset: Offset(
                                0,
                                -3 * bounce.clamp(0, 1),
                              ),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: colors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
