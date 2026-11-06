# Rumour 💬

**Your identity is a secret. Your conversations aren't.**

Rumour is an anonymous, room-code-based chat application built with **Flutter and Firebase**. Create a room, share its six-character code, and start chatting with people without revealing your real identity.

Every participant gets a randomly generated anonymous identity, such as **Brave Badger** or **Clever Fox**. Your identity stays consistent within a room, even when you leave and come back later.

No phone numbers, usernames, or complicated registration process. Just a room code and a conversation.

---

## 📲 Installation

### Android

You can install Rumour directly using the APK available in the GitHub Releases section.

1. Visit the [Rumour Releases](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/releases/latest) page.
2. Download the latest `app-release.apk` file.
3. Open the downloaded APK on your Android device.
4. If prompted, allow installation from unknown sources for your browser or file manager.
5. Complete the installation and launch Rumour.

> **Note:** Android may display a security warning when installing an APK downloaded outside the Play Store. Only install APKs from a release published by the repository owner.

**Download:** [Get the latest Android APK](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/releases/latest)

---

## ✨ Features

- **Anonymous identities:** Get a randomly generated adjective-and-animal identity for every room.
- **Room-based conversations:** Create or join conversations using unique six-character alphanumeric room codes.
- **Persistent identities:** Rejoining a room from the same device restores your previous identity.
- **Realtime messaging:** Messages appear instantly using Cloud Firestore.
- **Your Chats:** Access previously joined rooms without entering their codes again.
- **Paginated chat history:** Load older messages as you scroll through conversations.
- **Offline support:** Firestore's built-in offline persistence keeps previously available data accessible.
- **Live member count:** See how many members are currently recorded in a room.
- **Dark and light themes:** Switch between supported app themes.
- **Lightweight authentication:** Firebase Anonymous Authentication removes the need for traditional account registration.

---

## 📱 App Screens & User Flow

Rumour is designed around a simple flow: create or join a room, receive an anonymous identity, and start chatting.

### 1. Home Screen

The Home Screen is the starting point of the application.

From here, users can:
- Create a new room.
- Join an existing room using a six-character code.
- Open **Your Chats** to revisit previously joined rooms.
- Switch between app themes.

### 2. Create Room

Users can create a new anonymous chat room.

The app generates a unique six-character alphanumeric room code and creates the corresponding room in Firestore.

The room code can then be shared with other participants so they can join the same conversation.

### 3. Join Room

Users can enter an existing room using its six-character code.

The application validates the code and checks whether the room exists before proceeding.

Room codes support both letters and numbers.

### 4. Anonymous Identity Reveal

When someone joins a room for the first time, Rumour generates a random anonymous identity.

Examples:
- Brave Badger
- Clever Fox
- Silent Panther
- Curious Eagle

The identity is generated using random-user entropy mapped to a curated adjective-and-animal word list.

Users see their assigned identity before entering the chat.

The identity is cached locally for that room, allowing the same device to reuse it when rejoining.

### 5. Chat Screen

The Chat Screen is where conversations happen.

Features include:
- Realtime message delivery.
- Anonymous sender names.
- Message timestamps.
- Incoming and outgoing message bubbles.
- Live room member count.
- Paginated message history.
- Offline access to previously cached Firestore data.

Messages are associated with the anonymous identity assigned to the sender in that room.

### 6. Your Chats

Your Chats provides a list of rooms previously joined by the current device.

Instead of manually entering a room code every time, users can select a room and continue chatting with their existing identity.

The list is powered by Firestore rather than relying exclusively on locally stored room information.

Rooms are ordered by their most recent visit.

---

## 🔄 How Rumour Works

The typical user journey looks like this:

1. Open Rumour.
2. Create a room or enter an existing room code.
3. If joining for the first time, receive a randomly generated anonymous identity.
4. Acknowledge the identity and enter the room.
5. Start exchanging messages in realtime.
6. Leave the room whenever you want.
7. Return later through Your Chats and continue using the same identity.

```text
                 Open Rumour
                      |
                      v
                  Home Screen
                      |
             +--------+--------+
             |                 |
             v                 v
         Create Room         Join Room
             |                 |
             v                 v
       Generate Code       Enter Code
             |                 |
             +--------+--------+
                      |
                      v
              Check Room Identity
                      |
              +-------+-------+
              |               |
              v               v
         First Visit      Returning User
              |               |
              v               |
       Generate Identity       |
              |               |
              v               |
       Reveal Identity         |
              |               |
              +-------+-------+
                      |
                      v
                  Chat Screen
                      |
                      v
              Realtime Messaging
                      |
                      v
                  Your Chats
```

---

## 🛠️ Technology Stack

| Category | Technology |
|---|---|
| Mobile application | Flutter |
| Programming language | Dart |
| State management | Provider |
| Authentication | Firebase Anonymous Auth |
| Database | Cloud Firestore |
| Local identity storage | SharedPreferences |
| Identity entropy | Random User API |
| Navigation | Flutter Navigator |
| Animations | Flutter Animation Framework |
| Backend infrastructure | Firebase |

### Architecture

Rumour follows a service-oriented architecture using Provider for dependency injection and state management.

The main application services are:

| Service | Responsibility |
|---|---|
| `AuthService` | Anonymous Firebase authentication |
| `RoomService` | Room creation, membership, room lookup and member tracking |
| `ChatService` | Realtime messaging and paginated message history |
| `IdentityService` | Anonymous identity generation and local caching |

Additional services handle active room tracking, notifications, deep links, and message watching.

---

## 🗄️ Firestore Database Structure

Rumour uses Cloud Firestore as its primary database.

The database is organized around rooms, members, and messages.

```text
rooms/
  {roomCode}/
    code
    createdAt

    members/
      {uid}/
        uid
        displayName
        joinedAt
        lastVisitedAt

    messages/
      {messageId}/
        text
        senderUid
        senderName
        createdAt
```

### Rooms

Each room has a unique six-character code and creation timestamp.

### Members

Each member document represents a device's identity within a particular room.

It stores:
- Firebase Anonymous Auth UID.
- Anonymous display name.
- Join timestamp.
- Last visited timestamp.

The member document is the durable server-side record of the user's identity in that room.

### Messages

Every message stores:
- Message text.
- Sender UID.
- Sender's anonymous display name.
- Creation timestamp.

---

## ⚡ Realtime Messaging & Pagination

Rumour uses Firestore snapshot listeners to deliver messages in realtime.

The chat implementation:
- Listens to the latest 30 messages.
- Loads older messages when the user scrolls upward.
- Uses `startAfterDocument` for cursor-based pagination.
- Relies on Firestore's local cache for offline support.

This keeps the initial chat load lightweight while allowing users to access older conversations.

## 🔐 Authentication & Privacy

Rumour uses Firebase Anonymous Authentication.

A Firebase UID is automatically generated for each device and persists across application launches.

There is no conventional account registration process involving email addresses, phone numbers, or passwords.

Anonymous identities are room-specific and are stored against the authenticated UID in Firestore.

> **Privacy note:** Anonymous display names do not make conversations end-to-end encrypted or guarantee complete anonymity. Firebase UIDs and room membership records are stored by the application. Avoid sharing sensitive information in rooms.

---

# 👨‍💻 Developer Guide

This section explains how to set up the development environment, clone the repository, configure Firebase, and run Rumour locally.

## 1. Prerequisites

Make sure the following tools are installed:

| Tool | Purpose |
|---|---|
| Git | Clone and manage the repository |
| Flutter | Build and run the application |
| FVM | Manage Flutter SDK versions |
| Dart | Flutter development language |
| Android Studio | Android SDK and emulator |
| Firebase CLI | Firebase configuration and emulator management |
| Node.js and npm | Run Firebase CLI through npx |

### Recommended setup

Use the Flutter version pinned in the repository's `.fvmrc` file.

This ensures that everyone working on the project uses the same Flutter SDK version.

## 2. Install FVM

FVM (Flutter Version Management) allows you to manage multiple Flutter SDK versions and use a project-specific version.

Install FVM:

```bash
dart pub global activate fvm
```

Verify installation:

```bash
fvm --version
```

If the `fvm` command is not recognized, add Dart's global executable directory to your system PATH.

For macOS, this is commonly:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 3. Clone the Repository

Clone the project:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
```

Navigate into the project directory:

```bash
cd YOUR_REPOSITORY
```

## 4. Set Up Flutter Using FVM

Check the Flutter version specified by the repository:

```bash
cat .fvmrc
```

Install the project's pinned Flutter version:

```bash
fvm install
```

Use the project's Flutter SDK:

```bash
fvm flutter --version
```

Fetch dependencies:

```bash
fvm flutter pub get
```

**Important:** Use `fvm flutter` instead of `flutter` when running project commands to ensure the correct SDK version is used.

## 5. Firebase Configuration

Rumour is currently configured to use the Firebase project:

```text
rumour-87574
```

The repository includes:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

The Firebase options file is manually configured from the platform Firebase configuration files.

### Firebase services required

Before running against the production Firebase project, make sure the following are enabled in the Firebase Console:

1. Firestore Database in Native mode.
2. Firebase Authentication.
3. Anonymous Authentication provider.

The Firestore security rules and composite indexes must also be deployed.

To deploy them:

```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

The deployment requires access to the Firebase project.

## 6. Run the Application

Connect an Android device or start an Android emulator.

Check available devices:

```bash
fvm flutter devices
```

Run the application:

```bash
fvm flutter run
```

This starts Rumour against the configured production Firebase project.

## 7. Run Using Firebase Emulator Suite

You can also run Rumour locally using Firebase Authentication and Firestore emulators.

This is useful for development and testing without depending on the production Firebase services.

### Start the Firebase emulators

From the project directory, run:

```bash
npx firebase-tools emulators:start \
  --only firestore,auth \
  --project rumour-87574
```

The app is configured to connect to:
- Firebase Authentication Emulator: `9099`
- Firestore Emulator: `8080`

For Android emulators, the host is `10.0.2.2`. For other supported platforms, the configured host is `localhost`.

### Run Flutter against the emulators

Open another terminal in the project directory:

```bash
fvm flutter run \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

The application will now use the local Firebase emulators and the repository's Firestore security rules.

---

## 8. Build an Android APK

To generate a release APK:

```bash
fvm flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

You can upload this APK to the GitHub Releases section so users can download and install Rumour without building it themselves.

### Creating a GitHub Release

1. Open your GitHub repository.
2. Navigate to **Releases**.
3. Select **Draft a new release**.
4. Add a version tag, for example `v1.0.0`.
5. Upload `app-release.apk`.
6. Add release notes.
7. Publish the release.

---

## 9. Useful Flutter Commands

| Command | Description |
|---|---|
| `fvm install` | Install the Flutter SDK pinned by the project |
| `fvm flutter pub get` | Install project dependencies |
| `fvm flutter clean` | Clear generated build files |
| `fvm flutter analyze` | Analyze the Dart code |
| `fvm flutter test` | Run automated tests |
| `fvm flutter devices` | List connected devices |
| `fvm flutter run` | Run the application |
| `fvm flutter build apk --release` | Build the Android release APK |

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── theme.dart
│   └── page_transitions.dart
│
├── models/
│   ├── chat_message.dart
│   └── room_identity.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── create_room_screen.dart
│   ├── join_room_screen.dart
│   ├── identity_reveal_screen.dart
│   ├── chat_screen.dart
│   └── my_rooms_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── room_service.dart
│   ├── chat_service.dart
│   ├── identity_service.dart
│   └── ...
│
├── utils/
│   ├── room_code.dart
│   ├── word_lists.dart
│   └── date_formatter.dart
│
├── widgets/
│   ├── chat_bubble.dart
│   ├── pill_button.dart
│   └── ...
│
├── firebase_options.dart
└── main.dart

android/
ios/
firestore.rules
firestore.indexes.json
pubspec.yaml
.fvmrc
```

*The structure above is a high-level overview; additional files and services may exist in the repository.*

---

## ⚠️ Platform Notes

### Android

- Minimum Android SDK: 23.
- NDK version: `27.0.12077973`.
- Debug builds allow cleartext HTTP for communication with the local Firebase Emulator Suite.
- Release builds are not affected by the debug-only cleartext configuration.

### iOS

- Minimum deployment target: iOS 15.0.
- Current Firebase iOS SDK dependencies require this deployment target.

A known development-machine issue with a newer Xcode/iOS Simulator runtime has caused the app to fail to launch with:

```text
UIScene life cycle is required for apps built with this SDK
```

This is currently identified as a toolchain/runtime compatibility issue rather than a confirmed Dart application issue.

---

## 🤝 Contributing

Contributions, suggestions, and bug reports are welcome.

If you want to contribute:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Run Flutter analysis and tests.
5. Submit a pull request describing your changes.

```bash
git checkout -b feature/your-feature-name
```

---

## 📄 License

Add your chosen open-source license here before distributing the repository. Until a license is included, the repository should not be assumed to grant permission for reuse or redistribution.

---

**Built with Flutter ❤️ and Firebase.**