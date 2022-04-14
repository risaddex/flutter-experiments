import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';

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
        return 'Unknown error happened';
    }
  }
}
