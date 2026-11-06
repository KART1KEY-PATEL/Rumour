import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../app/page_transitions.dart';
import '../app/theme.dart';
import '../services/identity_service.dart';
import '../services/room_service.dart';
import '../utils/room_code.dart';
import '../widgets/pill_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'chat_screen.dart';
import 'identity_reveal_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key, this.initialCode, this.autoSubmit = false});

  final String? initialCode;

  final bool autoSubmit;

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  late final _controller = TextEditingController(
    text: widget.initialCode ?? '',
  );
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final code = widget.initialCode;
    if (widget.autoSubmit && code != null && isValidRoomCode(code)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _join());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = normalizeRoomCode(_controller.text);
    if (!isValidRoomCode(code)) {
      setState(() => _error = 'Enter the full 6-character room code.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final roomService = context.read<RoomService>();
      final identityService = context.read<IdentityService>();

      await roomService.assertRoomExists(code);

      final cached = await identityService.getCachedIdentity(code);
      final isFirstJoin = cached == null;
      final identity = cached ?? await identityService.createIdentity(code);

      if (!mounted) return;

      if (isFirstJoin) {
        await Navigator.of(context).pushReplacement(
          AppPageRoute(
            builder: (_) =>
                IdentityRevealScreen(roomCode: code, identity: identity),
          ),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          AppPageRoute(
            builder: (_) => ChatScreen(roomCode: code, identity: identity),
          ),
        );
      }
    } on RoomNotFoundException {
      setState(
        () => _error = 'Room not found. Check the code and try again.',
      );
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultPinTheme = PinTheme(
      width: 44,
      height: 52,
      textStyle: TextStyle(
        color: colors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'Join A Room',
                style: AppTextStyles.title(colors),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the code to join the anon chat room',
                style: AppTextStyles.subtitle(colors),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Center(
                child: Pinput(
                  length: kRoomCodeLength,
                  controller: _controller,
                  autofocus: widget.initialCode == null,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: colors.accent, width: 1.5),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme,
                  textCapitalization: TextCapitalization.characters,
                  onCompleted: (_) => _join(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: colors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              PillButton(
                label: 'Join Room',
                isLoading: _submitting,
                onPressed: _join,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
