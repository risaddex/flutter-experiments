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
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final AuthService _authService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _authService = AuthService.firebase();
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;

    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) return existingNote;

    final currentUser = _authService.currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUserByEmail(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
          future: createNewNote(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data as DatabaseNote;
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Type your note here...',
                  ),
                );

              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
