import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/util/dialogs/error_dialog.dart';

import 'package:notesapp/views/notes/notes_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';

class LoginView extends StatefulWidget {
  static const route = '/login/';
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController(text: 'danilo.romano@datagrupo.com.br');
    _password = TextEditingController(text: 'danilo.romano@datagrupo.com.br');
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService.firebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter your email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter your password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await _authService.logIn(
                  email: email,
                  password: password,
                );
                final user = _authService.currentUser;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    NotesView.route,
                    (route) => false,
                  );
                  return;
                }

                Navigator.of(context).pushNamedAndRemoveUntil(
                  VerifyEmailView.route,
                  (route) => false,
                );
              } on DomainException catch (e) {
                await showErrorDialog(context, e.getDomainMessage());
              } catch (e) {
                showErrorDialog(
                  context,
                  'An error ocurred.',
                );
                devtools.log(e.toString());
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RegisterView.route,
                (route) => false,
              );
            },
            child: const Text('not registered yet, register here!'),
          )
        ],
      ),
    );
  }
}
