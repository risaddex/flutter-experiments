import 'package:flutter/widgets.dart';
import 'package:notesapp/main.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/register_view.dart';

final Map<String, WidgetBuilder> routes = {
  LoginView.route: (context) => const LoginView(),
  RegisterView.route: (context) => const RegisterView(),
  NotesView.route: (context) => const NotesView(),
};
