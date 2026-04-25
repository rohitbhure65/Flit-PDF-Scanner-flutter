import 'package:firebase_auth/firebase_auth.dart';
import 'package:flitpdf/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    StorageService? storageService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _storageService = storageService ?? StorageService();

  static const String _serverClientId = String.fromEnvironment(
    'FLITPDF_GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '715346774495-r87jc1sf0itj8a3leei28ehfdg1vq710.apps.googleusercontent.com',
  );

  static Future<void>? _initializationFuture;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final StorageService _storageService;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      await _ensureInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'Google Sign-In is not supported on this platform.',
        );
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google Sign-In did not return an ID token.');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        throw StateError('Firebase sign-in did not return a user.');
      }

      await _storageService.saveUserData(
        name:
            user.displayName ??
            googleUser.displayName ??
            _nameFromEmail(user.email ?? googleUser.email),
        email: user.email ?? googleUser.email,
        photoUrl: user.photoURL ?? googleUser.photoUrl,
        uid: user.uid,
      );

      return user;
    } on GoogleSignInException catch (error) {
      debugPrint('Google Sign-In error: $error');
      if (_isCancellation(error)) {
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      _showSnackBar(context, _messageForGoogleError(error));
      return null;
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase auth error: $error');
      if (!context.mounted) {
        return null;
      }
      _showSnackBar(context, error.message ?? 'Google sign-in failed.');
      return null;
    } catch (error) {
      debugPrint('Sign in error: $error');
      if (!context.mounted) {
        return null;
      }
      _showSnackBar(context, 'Unable to sign in with Google.');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      debugPrint('Firebase sign out error: $error');
    }

    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google sign out error: $error');
    } finally {
      await _storageService.clearUserData();
    }
  }

  Future<void> _ensureInitialized() {
    return _initializationFuture ??= _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
    } catch (_) {
      _initializationFuture = null;
      rethrow;
    }
  }

  bool _isCancellation(GoogleSignInException error) {
    return error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted;
  }

  String _messageForGoogleError(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was canceled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in is not configured correctly for this build.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in is unavailable right now.';
      default:
        return 'Unable to sign in with Google.';
    }
  }

  String _nameFromEmail(String email) {
    final String localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'User';
    }
    return localPart;
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }

    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}
