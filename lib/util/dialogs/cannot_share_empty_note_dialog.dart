import 'package:flutter/material.dart';
import 'package:notesapp/util/dialogs/generic_dialog.dart';

Future<void> showCannonShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: "You can't share an empty note!",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
