import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/page_transitions.dart';
import '../app/theme.dart';
import '../models/joined_room.dart';
import '../services/auth_service.dart';
import '../services/identity_service.dart';
import '../services/room_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'identity_reveal_screen.dart';
import 'join_room_screen.dart';
import 'my_rooms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _creating = false;
  String? _error;

  Future<void> _createRoom() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final roomService = context.read<RoomService>();
      final identityService = context.read<IdentityService>();
      final code = await roomService.createRoom();
      final identity = await identityService.createIdentity(code);
      if (!mounted) return;
      await Navigator.of(context).push(
        AppPageRoute(
          builder: (_) =>
              IdentityRevealScreen(roomCode: code, identity: identity),
        ),
      );
    } catch (_) {
      setState(() => _error = 'Could not create a room. Please try again.');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _openYourChats() {
    Navigator.of(
      context,
    ).push(AppPageRoute(builder: (_) => const MyRoomsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        'assets/icon/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Rumour',
                    style: AppTextStyles.title(colors),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a room to start an anonymous chat,\nor join one with a room code.',
                    style: AppTextStyles.subtitle(colors),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  _YourChatsEntry(onTap: _openYourChats),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(color: colors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  PillButton(
                    label: 'Create a Room',
                    isLoading: _creating,
                    onPressed: _createRoom,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _creating
                          ? null
                          : () => Navigator.of(context).push(
                              AppPageRoute(
                                builder: (_) => const JoinRoomScreen(),
                              ),
                            ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.surfaceVariant),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Join a Room',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const Positioned(top: 0, right: 8, child: ThemeToggleButton()),
          ],
        ),
      ),
    );
  }
}

class _YourChatsEntry extends StatelessWidget {
  const _YourChatsEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = context.watch<AuthService>().uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<JoinedRoom>>(
      stream: context.read<RoomService>().joinedRoomsStream(uid),
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? const <JoinedRoom>[];
        if (rooms.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.accent),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_rounded, color: colors.accent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Your Chats (${rooms.length})',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
