import 'package:flutter/foundation.dart';
import 'package:notesapp/domain/entities/auth_user.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin({
    required this.email,
    required this.password,
  });
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
