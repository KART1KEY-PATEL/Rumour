import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/page_transitions.dart';
import '../app/theme.dart';
import '../models/joined_room.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/theme_toggle_button.dart';
import 'chat_screen.dart';

class MyRoomsScreen extends StatelessWidget {
  const MyRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = context.read<AuthService>().uid;
    final roomService = context.read<RoomService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Your Chats', style: AppTextStyles.headerTitle(colors)),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: uid == null
            ? const _EmptyState(
                message: 'Sign-in is still in progress. Please try again.',
              )
            : StreamBuilder<List<JoinedRoom>>(
                stream: roomService.joinedRoomsStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: colors.accent),
                    );
                  }
                  final rooms = snapshot.data ?? const <JoinedRoom>[];
                  if (rooms.isEmpty) {
                    return const _EmptyState(
                      message:
                          'No chats yet. Create or join a room to get started.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => Divider(
                      color: colors.surfaceVariant,
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.surface,
                          child: Text(
                            room.displayName.isNotEmpty
                                ? room.displayName[0]
                                : '?',
                            style: TextStyle(
                              color: colors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          'Room #${room.roomCode}',
                          style: AppTextStyles.headerTitle(
                            colors,
                          ).copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          'You are ${room.displayName}',
                          style: AppTextStyles.subtitle(
                            colors,
                          ).copyWith(fontSize: 13),
                        ),
                        trailing: Text(
                          '${formatDateSeparator(room.lastVisitedAt)}\n${formatMessageTime(room.lastVisitedAt)}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.timestamp(colors),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => ChatScreen(
                                roomCode: room.roomCode,
                                identity: room.identity,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          style: AppTextStyles.subtitle(colors),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
