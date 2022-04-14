import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/util/show_error_dialog.dart';

extension HandleError on FirebaseAuthException {
  Future<void> handleFirebaseAuthError(BuildContext context) {
    switch (code) {
      case ('user-not-found'):
        {
          return showErrorDialog(
            context,
            'User not found',
          );
        }

      case ('wrong-password'):
        {
          return showErrorDialog(
            context,
            'Invalid Credentials',
          );
        }

      default:
        {
          devtools.log(toString());
          return showErrorDialog(
            context,
            'Error: ${message.toString()}\n\nCode: $code',
          );
        }
    }
  }
}
