abstract class DomainException implements Exception {
  String getDomainMessage();
}

// login exceptions
class UserNotFoundAuthException implements DomainException {
  @override
  String getDomainMessage() => 'User not found';
}

class WrongPasswordAuthException implements DomainException {
  @override
  String getDomainMessage() => 'Invalid credentials';
}

// register exceptions
class WeakPasswordAuthException implements DomainException {
  @override
  String getDomainMessage() => 'Weak password';
}

class EmailAlreadyInUseAuthException implements DomainException {
  @override
  String getDomainMessage() => 'Email already in use';
}

class InvalidEmailAuthException implements DomainException {
  @override
  String getDomainMessage() => 'Invalid email';
}

// generic exceptions

class GeneralAuthException implements DomainException {
  @override
  String getDomainMessage() => 'An exception ocurred';
}

class UserNotLoggedInAuthException implements DomainException {
  @override
  String getDomainMessage() => 'User not logged in';
}
