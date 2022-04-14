import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/util/show_error_dialog.dart';
import 'package:notesapp/views/verify_email_view.dart';

class RegisterView extends StatefulWidget {
  static const route = '/register/';
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
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
        title: const Text('Register'),
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
                await _authService.createUser(
                  email: email,
                  password: password,
                );

                await _authService.sendEmailVerification();

                Navigator.of(context).pushNamed(VerifyEmailView.route);
              } on DomainException catch (e) {
                await showErrorDialog(context, e.getDomainMessage());
              } catch (e) {
                devtools.log(e.toString());
                showErrorDialog(
                  context,
                  'An error ocurred.',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/',
                  (route) => false,
                );
              },
              child: const Text('Already registered? login !'))
        ],
      ),
    );
  }
}
