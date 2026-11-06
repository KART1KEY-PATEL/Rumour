import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/page_transitions.dart';
import '../app/theme.dart';
import '../models/room_identity.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'chat_screen.dart';

class IdentityRevealScreen extends StatefulWidget {
  const IdentityRevealScreen({
    super.key,
    required this.roomCode,
    required this.identity,
  });

  final String roomCode;
  final RoomIdentity identity;

  @override
  State<IdentityRevealScreen> createState() => _IdentityRevealScreenState();
}

class _IdentityRevealScreenState extends State<IdentityRevealScreen>
    with SingleTickerProviderStateMixin {
  bool _continuing = false;

  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();
  late final Animation<double> _revealFade = CurvedAnimation(
    parent: _revealController,
    curve: Curves.easeOut,
  );
  late final Animation<double> _revealScale = Tween<double>(
    begin: 0.9,
    end: 1,
  ).animate(
    CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _continuing = true);
    try {
      final uid = context.read<AuthService>().uid!;
      await context.read<RoomService>().addMember(
        roomCode: widget.roomCode,
        uid: uid,
        displayName: widget.identity.displayName,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder:
              (_) => ChatScreen(
                roomCode: widget.roomCode,
                identity: widget.identity,
              ),
        ),
      );
    } finally {
      if (mounted) setState(() => _continuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Container(
            margin: EdgeInsets.all(7),

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff1F2937),
            ),
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_left,
              color: colors.textPrimary,
              size: 30,
            ),
          ),
          onTap: () => Navigator.of(context).maybePop(),
        ),

        title: Column(
          children: [
            Text(
              'Room #${widget.roomCode}',
              style: AppTextStyles.headerTitle(colors),
            ),
            StreamBuilder<int>(
              stream: context.read<RoomService>().memberCountStream(
                widget.roomCode,
              ),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 1;
                return Text(
                  '$count member${count == 1 ? '' : 's'}',
                  style: AppTextStyles.headerSubtitle(colors),
                );
              },
            ),
          ],
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _revealFade,
                child: ScaleTransition(
                  scale: _revealScale,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'For this room, you are',
                          style: AppTextStyles.identityLabel(colors),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.identity.displayName,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.identityName(colors).copyWith(
                            foreground:
                                Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color(0xFFFDE047),
                                      Color(0xFFA3E635),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 300, 100),
                                  ),
                                  fontSize: 50, fontWeight: FontWeight.w900,
                          ),
                          
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This is your anonymous identifier, visible only to others in this room.',
                          style: AppTextStyles.identityHint(colors),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // const Spacer(flex: ),
              SizedBox(height: 20),
              PillButton(
                label: 'Acknowledge and continue',
                isLoading: _continuing,
                onPressed: _continue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
