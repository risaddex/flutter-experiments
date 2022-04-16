import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/cloud_store_constants.dart';
import 'package:notesapp/services/cloud/cloud_store_exceptions.dart'
    as cloud_exceptions hide CloudStorageException;

class FirebaseCloudStorage {
  static const _notesCollectionName = 'notes';
  final notes = FirebaseFirestore.instance.collection(_notesCollectionName);

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw cloud_exceptions.CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw cloud_exceptions.CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      var result =
          await notes.where(ownerUserIdFieldName, isEqualTo: ownerUserId).get();

      return result.docs.map((e) => CloudNote.fromSnapshot(e));
    } catch (e) {
      throw cloud_exceptions.CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    try {
      await notes.add({
        ownerUserId: ownerUserId,
        textFieldName: '',
      });
    } catch (e) {
      throw cloud_exceptions.CouldNotCreateNoteException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
