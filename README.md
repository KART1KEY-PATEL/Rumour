# Rumour

Anonymous room-code chat app built with Flutter and Firebase (Firestore + Anonymous Auth).

Join or create a 6-character room code, get a random anonymous identity for that room
(e.g. "Brave Badger"), and chat in realtime with paginated history and offline support.

## Architecture

- **State**: `provider` services (`AuthService`, `RoomService`, `ChatService`, `IdentityService`) in `lib/services/`.
- **Firestore schema**:
  ```
  rooms/{code}                        { code, createdAt }
  rooms/{code}/members/{uid}          { uid, displayName, joinedAt, lastVisitedAt }
  rooms/{code}/messages/{messageId}   { text, senderUid, senderName, createdAt }
  ```
  The member doc is the durable, server-side record of "this device's identity in this room" —
  `uid` + `displayName` are written there (not just cached locally), and `lastVisitedAt` is bumped
  every time the room's chat is opened (`RoomService.touchMember`, called from `ChatScreen.initState`).
- **Identity**: calls `GET https://randomuser.me/api/` for entropy, maps it into a curated
  adjective+animal word list (`lib/utils/word_lists.dart`) to produce handles like "Brave Badger".
  Also cached locally per room via `shared_preferences`, so rejoining a room from the same device
  reuses the same identity and skips the identity-reveal screen without needing a network round-trip.
- **Auth**: one Firebase Anonymous Auth UID per device (persists automatically across launches).
- **Your Chats** (`lib/screens/my_rooms_screen.dart`): lists every room this device is a member of,
  so you can continue a chat with the same identity without re-entering its code. Sourced live from
  Firestore via a `collectionGroup('members').where('uid', isEqualTo: ...)` query
  (`RoomService.joinedRoomsStream`), ordered by `lastVisitedAt` — not from local-only state, so it's
  consistent with what's actually stored server-side. A "Your Chats (N)" entry appears on the Home
  screen once it's non-empty.
- **Pagination**: realtime listener on the latest 30 messages; scrolling up fetches older pages
  with `startAfterDocument`.
- **Offline**: relies on `cloud_firestore`'s built-in offline persistence — no custom cache. This
  also covers the Your Chats list and member docs, not just messages.

## Firebase project

This app is wired to Firebase project **`rumour-87574`**. `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist` are already in place, and `lib/firebase_options.dart` was
hand-written from their values (see the comment at the top of that file for why — `flutterfire
configure` hit a missing-gem crash on this machine partway through and never got to generate it).

Two things only the project owner can do (need Firebase console / `firebase login`, which this
assistant can't do non-interactively):

1. Confirm **Firestore (Native mode)** and the **Anonymous** sign-in provider are enabled on
   `rumour-87574` in the Firebase console.
2. Run `firebase login && firebase deploy --only firestore:rules,firestore:indexes` to publish
   `firestore.rules` and the composite index `firestore.indexes.json` needs for the Your Chats
   collection-group query (until then, the live project uses its default locked-down rules, and
   that query will fail with a "requires an index" error carrying a console link to create it).

If you ever want `flutterfire configure` itself to work again (e.g. to add another platform or
rotate config), the missing pieces on this machine were the `xcodeproj`/`cocoapods` Ruby gems:
`gem install xcodeproj cocoapods`.

## Running against the local Firebase Emulator Suite

You don't need the two steps above to try the app locally — it can run entirely against the
Firestore + Auth emulators, using this repo's real `firestore.rules`:

```bash
npx firebase-tools emulators:start --only firestore,auth --project rumour-87574
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

This was the setup used to verify the app end-to-end (create/join rooms, identity generation,
realtime multi-user chat, offline cache) during development.

## Known platform notes

- **Android**: `minSdk` is 23 and `ndkVersion` is pinned to `27.0.12077973` — both required by the
  Firebase Android SDKs this app depends on. The debug build allows cleartext HTTP
  (`android/app/src/debug/AndroidManifest.xml`) so it can reach the emulator's `10.0.2.2` loopback;
  release builds are unaffected.
- **iOS**: deployment target is 15.0 (required by current Firebase iOS SDKs and this machine's
  Xcode). On this machine's very new Xcode/iOS Simulator runtime, the built app currently fails to
  launch with `UIScene life cycle is required for apps built with this SDK` — a toolchain/runtime
  issue unrelated to the app's Dart code, not yet resolved here.
# Rumour
