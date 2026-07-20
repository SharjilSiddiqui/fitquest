import 'package:flutter/foundation.dart';

import 'package:dartstream_client/dartstream_client.dart';

import '../services/dartstream_client_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SessionStatus { signedOut, signingIn, signedIn, error }

class Session extends ChangeNotifier {
  SessionStatus status = SessionStatus.signedOut;
  String? email;
  String? userId;
  String? tenantId;
  String? errorMessage;
  DartStreamSession? dartStreamSession;

  DartStreamClientService get dartStream => DartStreamClientService.instance;

  Future<void> signIn(String email, String password) async {
    status = SessionStatus.signingIn;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await dartStream.signIn(email: email, password: password);

      dartStreamSession = session;
      this.email = session.email ?? email;
      userId = session.userId;
      tenantId = session.tenantId;

      status = SessionStatus.signedIn;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    status = SessionStatus.signingIn;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await dartStream.signUp(email: email, password: password);

      dartStreamSession = session;
      this.email = session.email ?? email;
      userId = session.userId;
      tenantId = session.tenantId;

      status = SessionStatus.signedIn;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    status = SessionStatus.signingIn;
    errorMessage = null;
    notifyListeners();

    try {
      final googleSignIn = GoogleSignIn(
        clientId:
            '420891456414-olomuv6sp93iksu5t0vqk3r9rn12o91f.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        status = SessionStatus.signedOut;
        notifyListeners();
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final firebaseIdToken = await userCredential.user!.getIdToken();

      final session = await dartStream.signInWithFirebaseIdToken(
        firebaseIdToken!,
      );

      dartStreamSession = session;
      email = session.email ?? googleUser.email;
      userId = session.userId;
      tenantId = session.tenantId;

      status = SessionStatus.signedIn;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  void signOut() {
    status = SessionStatus.signedOut;
    email = null;
    userId = null;
    tenantId = null;
    errorMessage = null;
    dartStreamSession = null;
    dartStream.clearSession();
    notifyListeners();
  }
}
