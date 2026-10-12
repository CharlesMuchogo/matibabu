import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';

class SocialCredential extends Equatable {
  final String token;
  final String firstName;
  final String lastName;

  const SocialCredential({
    required this.token,
    this.firstName = '',
    this.lastName = '',
  });

  @override
  List<Object?> get props => [token, firstName, lastName];
}

abstract class SocialAuth {
  Future<SocialCredential?> signIn(SocialProvider provider);

  Future<void> signOut();
}

class FirebaseSocialAuth implements SocialAuth {
  static const _cancelledCodes = {'canceled', 'web-context-canceled'};

  final FirebaseAuth? _firebaseAuth;
  bool _googleReady = false;

  FirebaseSocialAuth([this._firebaseAuth]);

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  Future<GoogleSignIn> _google() async {
    if (!_googleReady) {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    }
    return GoogleSignIn.instance;
  }

  @override
  Future<SocialCredential?> signIn(SocialProvider provider) async {
    try {
      final result = switch (provider) {
        SocialProvider.google => await _signInWithGoogle(),
        SocialProvider.apple => await _auth.signInWithProvider(
          AppleAuthProvider()
            ..addScope('email')
            ..addScope('name'),
        ),
      };
      if (result == null) return null;
      return await _credentialFrom(result);
    } on FirebaseAuthException catch (e) {
      if (_cancelledCodes.contains(e.code)) return null;
      throw AppException(e.message ?? e.code);
    } finally {
      await _auth.signOut();
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final account = await (await _google()).authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AppException("Google didn't return a sign in token.");
      }
      return _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      final misconfigured = e.description?.contains('[16]') ?? false;
      if (!misconfigured &&
          (e.code == GoogleSignInExceptionCode.canceled ||
              e.code == GoogleSignInExceptionCode.interrupted)) {
        return null;
      }
      throw AppException(
        misconfigured
            ? "Google sign in isn't set up for this build of the app."
            : e.description ?? e.code.name,
      );
    }
  }

  Future<SocialCredential> _credentialFrom(UserCredential result) async {
    final token = await result.user?.getIdToken();
    if (token == null) {
      throw const AppException("Couldn't verify your account. Try again.");
    }
    final profile = result.additionalUserInfo?.profile ?? const {};
    final [first, ...rest] = (result.user?.displayName ?? '').trim().split(
      RegExp(r'\s+'),
    );
    return SocialCredential(
      token: token,
      firstName: '${profile['given_name'] ?? profile['firstName'] ?? first}',
      lastName:
          '${profile['family_name'] ?? profile['lastName'] ?? rest.join(' ')}',
    );
  }

  @override
  Future<void> signOut() async {
    if (!_googleReady) return;
    try {
      await GoogleSignIn.instance.signOut();
    } on GoogleSignInException {
      return;
    }
  }
}
