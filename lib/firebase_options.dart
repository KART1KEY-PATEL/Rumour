import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'this app targets Android and iOS only.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFnRvjiouCvtFQAFlLx5J6g4EOnpnYIqA',
    appId: '1:921465975327:android:ec3eb82dc9818315d51b2a',
    messagingSenderId: '921465975327',
    projectId: 'rumour-87574',
    databaseURL: 'https://rumour-87574-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rumour-87574.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqUNsqCrSxGj4-hHiKQQJ_xDhmJM1Ouco',
    appId: '1:921465975327:ios:ade49214c8fe5239d51b2a',
    messagingSenderId: '921465975327',
    projectId: 'rumour-87574',
    databaseURL: 'https://rumour-87574-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rumour-87574.firebasestorage.app',
    iosBundleId: 'com.example.rumour',
  );
}
