import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../app/page_transitions.dart';
import '../screens/join_room_screen.dart';

class DeepLinkService {
  DeepLinkService(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> start() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handleUri(initial);
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void handlePayload(String payload) {
    final uri = Uri.tryParse(payload);
    if (uri != null) _handleUri(uri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'rumour' || uri.host != 'room') return;
    if (uri.pathSegments.isEmpty) return;
    handleRoomDeepLink(uri.pathSegments.first.toUpperCase());
  }

  void handleRoomDeepLink(String roomCode) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      AppPageRoute(
        builder: (_) =>
            JoinRoomScreen(initialCode: roomCode, autoSubmit: true),
      ),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
