import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notesapp/domain/entities/user.entity.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user == null) {
        throw UserNotFoundAuthException();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.getDomainException();
    } catch (_) {
      throw GeneralAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    return AuthUser.fromFirebase(user);
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user == null) {
        throw UserNotLoggedInAuthException();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.getDomainException();
    } catch (_) {
      throw GeneralAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException();
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotLoggedInAuthException();
    }

    await user.sendEmailVerification();
  }
}

extension ErrorMapper on FirebaseAuthException {
  Exception getDomainException() {
    switch (code) {
      case ('user-not-found'):
        return UserNotFoundAuthException();

      case ('wrong-password'):
        return WrongPasswordAuthException();

      case ('email-already-in-use'):
        return EmailAlreadyInUseAuthException();

      default:
        return GeneralAuthException();
    }
  }

  String getDomainMessage() {
    switch (code) {
      case ('user-not-found'):
        return 'User not found';

      case ('wrong-password'):
        return 'Invalid credentials';

      case ('email-already-in-use'):
        return 'Email already in use';

      default:
        devtools.log(code);
        return 'Error: $message';
    }
  }
}
