import 'package:flutter/widgets.dart';
import 'package:notesapp/views/notes/create_update_note_view.dart';
// import 'package:notesapp/views/login_view.dart';
// import 'package:notesapp/views/notes/notes_view.dart';
// import 'package:notesapp/views/register_view.dart';
// import 'package:notesapp/views/verify_email_view.dart';

final Map<String, WidgetBuilder> routes = {
  // LoginView.route: (context) => const LoginView(),
  // RegisterView.route: (context) => const RegisterView(),
  // NotesView.route: (context) => const NotesView(),
  // VerifyEmailView.route: (context) => const VerifyEmailView(),
  CreateUpdateNoteView.route: (context) => const CreateUpdateNoteView(),
};
