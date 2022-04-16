import 'package:flutter/foundation.dart';
import 'package:notesapp/domain/entities/auth_user.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateLoginFailure extends AuthState {
  final DomainException exception;
  const AuthStateLoginFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthStateLogoutFailure extends AuthState {
  final DomainException exception;
  const AuthStateLogoutFailure(this.exception);
}
