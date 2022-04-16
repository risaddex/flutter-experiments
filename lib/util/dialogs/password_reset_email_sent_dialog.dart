import 'package:flutter/material.dart';
import 'package:notesapp/util/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Password Reset',
      content:
          'We have now send a password reset link. Please check out your email',
      optionsBuilder: () => {
            'OK': null,
          });
}
