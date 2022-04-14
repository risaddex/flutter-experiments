import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/views/register_view.dart';

class VerifyEmailView extends StatefulWidget {
  static const route = '/verify-email/';
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final _authService = AuthService.firebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification. Please open it to verify your account."),
          const Text(
              "You you haven't received the email yet, press the button bellow"),
          TextButton(
            onPressed: () async {
              await _authService.sendEmailVerification();
            },
            child: const Text('Verify your email'),
          ),
          TextButton(
            onPressed: () async {
              _authService.logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                RegisterView.route,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
