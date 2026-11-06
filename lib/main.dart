import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/active_room_tracker.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/deep_link_service.dart';
import 'services/identity_service.dart';
import 'services/message_watcher_service.dart';
import 'services/notification_service.dart';
import 'services/room_service.dart';
import 'services/theme_controller.dart';

const bool kUseFirebaseEmulator = bool.fromEnvironment(
  'USE_FIREBASE_EMULATOR',
);

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode && kUseFirebaseEmulator) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const RumourApp());
}

class RumourApp extends StatelessWidget {
  const RumourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
        ChangeNotifierProvider(
          create: (_) => AuthService(FirebaseAuth.instance)..ensureSignedIn(),
        ),
        ChangeNotifierProvider(create: (_) => ActiveRoomTracker()),
        Provider(create: (_) => RoomService(FirebaseFirestore.instance)),
        Provider(create: (_) => ChatService(FirebaseFirestore.instance)),
        Provider(create: (_) => IdentityService()),
        Provider(create: (_) => NotificationService()),
        Provider(create: (_) => DeepLinkService(navigatorKey)),
        Provider(
          create: (context) => MessageWatcherService(
            roomService: context.read<RoomService>(),
            chatService: context.read<ChatService>(),
            notificationService: context.read<NotificationService>(),
            activeRoomTracker: context.read<ActiveRoomTracker>(),
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Rumour',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeController.mode,
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _servicesStarted = false;

  void _startBackgroundServices(String uid) {
    if (_servicesStarted) return;
    _servicesStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deepLinkService = context.read<DeepLinkService>();
      context.read<NotificationService>().initialize(
        onTap: deepLinkService.handlePayload,
      );
      deepLinkService.start();
      context.read<MessageWatcherService>().start(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final uid = auth.uid;
        if (!auth.isSignedIn || uid == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: context.colors.accent),
            ),
          );
        }
        _startBackgroundServices(uid);
        return const HomeScreen();
      },
    );
  }
}
