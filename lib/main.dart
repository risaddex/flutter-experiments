import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/notes/notes_view.dart';

import 'package:notesapp/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: routes,
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService.firebase();

    return FutureBuilder(
      future: _authService.initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = _authService.currentUser;
            if (user == null) {
              return const LoginView();
            }

            if (user.isEmailVerified) {
              devtools.log('Email is verified');
            } else {
              return const VerifyEmailView();
            }

            return const NotesView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

