import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialCode ?? '',
  );

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final code = widget.initialCode;

    if (widget.autoSubmit && code != null && isValidRoomCode(code)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _join(code);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join([String? enteredCode]) async {
    final code = normalizeRoomCode(enteredCode ?? _controller.text);

    if (!isValidRoomCode(code)) {
      setState(() {
        _error = 'Enter the full 6-character room code.';
      });
      return;
    }

    if (_submitting) return;

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

      await Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder:
              (_) =>
                  isFirstJoin
                      ? IdentityRevealScreen(roomCode: code, identity: identity)
                      : ChatScreen(roomCode: code, identity: identity),
        ),
      );
    } on RoomNotFoundException {
      if (mounted) {
        setState(() {
          _error = 'Room not found. Check the code and try again.';
        });
      }
    } catch (e) {
      debugPrint('Join room error: $e');

      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final defaultPinTheme = PinTheme(
      width: 35,
      height: 55,
      textStyle: TextStyle(
        color: colors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
      // padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffA1A1AA), width: 4)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.accent, width: 4.5)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Container(
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff1F2937),
            ),
            // padding: EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_left,
              color: colors.textPrimary,
              size: 30,
            ),
          ),
          onTap: () => Navigator.of(context).maybePop(),
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
                  child: Image.asset(
                    'assets/icon/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 100),

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

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xff27272A),
                ),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Pinput(
                    length: kRoomCodeLength,
                    controller: _controller,

                    autofocus: widget.initialCode == null,

                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,

                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],

                    enabled: !_submitting,

                    onChanged: (_) {
                      if (_error != null) {
                        setState(() {
                          _error = null;
                        });
                      }
                    },

                    onCompleted: (value) => _join(value),
                  ),
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

              // PillButton(
              //   label: 'Join Room',
              //   isLoading: _submitting,
              //   onPressed: _join,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
