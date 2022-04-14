import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/extensions/firebase_auth_exception.dart';
import 'package:notesapp/main.dart';
import 'package:notesapp/views/register_view.dart';

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
                final userCredential =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                Navigator.of(context).pushNamedAndRemoveUntil(
                  NotesView.route,
                  (route) => false,
                );

                devtools.log(userCredential.toString());
              } on FirebaseAuthException catch (e) {
                e.handleFirebaseAuthError(context);
              } catch (e) {
                devtools.log('something Bag happened');
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
