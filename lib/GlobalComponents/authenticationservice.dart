import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  AuthenticationService(this._auth);

  bool _googleInitialized = false;

  Future<GoogleSignIn> _google() async {
    if (!_googleInitialized) {
      // Client IDs come from google-services.json (Android) and
      // GoogleService-Info.plist (iOS).
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
    return GoogleSignIn.instance;
  }

  Stream<User?> get authstateChanges => _auth.authStateChanges();
  User? get userid => _auth.currentUser;

  /// Throws [FirebaseAuthException] on failure.
  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Throws [FirebaseAuthException] on failure.
  Future<void> signUp({required String email, required String password}) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Signs in with Google and creates the patient profile on first sign in.
  ///
  /// Throws [GoogleSignInException] (including when the account picker is
  /// dismissed) or [FirebaseAuthException] on failure.
  Future<void> signInWithGoogle() async {
    final google = await _google();
    final account = await google.authenticate();

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: "missing-id-token",
        message: "Google didn't return an ID token. Check that the web "
            "client ID in your Firebase config is correct.",
      );
    }

    final result = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    await _ensurePatientProfile(result.user!);
  }

  Future<void> _ensurePatientProfile(User user) async {
    final doc = FirebaseFirestore.instance.collection("Patient").doc(user.uid);
    if ((await doc.get()).exists) return;

    final names = (user.displayName ?? "").trim().split(RegExp(r"\s+"));
    await doc.set({
      "id": user.uid,
      "First Name": names.first,
      "Last Name": names.length > 1 ? names.sublist(1).join(" ") : "",
      "Email": user.email ?? "",
      "Profile Photo": user.photoURL ?? "https://bit.ly/3QR1Z8n",
      "Phone Number": user.phoneNumber ?? "",
      "Address": "",
    });
  }

  Future<void> signOut() async {
    // Also sign out of Google so the account picker shows next time.
    if (_auth.currentUser?.providerData
            .any((p) => p.providerId == GoogleAuthProvider.PROVIDER_ID) ??
        false) {
      await (await _google()).signOut();
    }
    await _auth.signOut();
  }
}
