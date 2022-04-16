import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:notesapp/services/auth/firebase_auth_provider.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/notes/notes_view.dart';
import 'package:notesapp/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: routes,
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      switch (state.runtimeType) {
        case AuthStateLoggedIn:
          return const NotesView();
        case AuthStateNeedsVerification:
          return const VerifyEmailView();
        case AuthStateLoggedOut:
          return const LoginView();
        default:
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
      }
    });
  }
}
