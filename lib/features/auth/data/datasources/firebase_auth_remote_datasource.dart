import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'auth_remote_datasource.dart';

@LazySingleton(as: AuthRemoteDataSource)
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRemoteDataSource(this._auth, this._googleSignIn);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<UserEntity?> getCurrentUser() async => _mapUser(_auth.currentUser);

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _requireUser(credential.user);
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null) {
      await credential.user?.updateDisplayName(displayName);
    }
    return _requireUser(credential.user);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Google sign-in aborted');
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final credential = await _auth.signInWithCredential(oauthCredential);
    return _requireUser(credential.user);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  UserEntity? _mapUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  UserEntity _requireUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) throw Exception('Firebase returned null user');
    return mapped;
  }
}
