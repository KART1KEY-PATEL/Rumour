import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  User? _user;

  User? get user => _user;
  String? get uid => _user?.uid;
  bool get isSignedIn => _user != null;

  Future<void> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) {
      _user = current;
      notifyListeners();
      return;
    }
    final credential = await _auth.signInAnonymously();
    _user = credential.user;
    notifyListeners();
  }
}
