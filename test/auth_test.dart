import 'dart:math';

import 'package:notesapp/domain/entities/auth_user.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn', () async {
      final badEmailUser = provider.createUser(
        email: MockAuthProvider.invalidEmail,
        password: 'password',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.createUser(
        email: 'valid@email.com',
        password: MockAuthProvider.invalidPassword,
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final validUser = await provider.createUser(
        email: 'valid@email.com',
        password: 'validPassword',
      );

      expect(provider.currentUser, validUser);
      expect(validUser.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  /// throws [UserNotFoundAuthException]
  static const invalidEmail = 'foo@bar.com';

  /// throws [WrongPasswordAuthException]
  static const invalidPassword = 'foobar';

  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void _assertIsInitialized() {
    if (!isInitialized) throw NotInitializedException();
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    _assertIsInitialized();

    await Future.delayed(const Duration(seconds: 1));

    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    _assertIsInitialized();
    if (email == invalidEmail) throw UserNotFoundAuthException();
    if (password == invalidPassword) throw WrongPasswordAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: 'email@email.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    _assertIsInitialized();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    _assertIsInitialized();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    _user = const AuthUser(isEmailVerified: true, email: '');
  }
}
