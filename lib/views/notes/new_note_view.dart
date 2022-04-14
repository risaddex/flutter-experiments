import 'package:flutter/material.dart';
import 'package:notesapp/enums/menu_action.dart';
import 'package:notesapp/main.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  static const route = '/notes/new/';
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Text('Here should be the view'),
    );
  }
}
