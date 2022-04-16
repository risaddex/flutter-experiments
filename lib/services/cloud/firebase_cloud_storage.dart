import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/cloud_store_constants.dart';
import 'package:notesapp/services/cloud/cloud_store_exceptions.dart'
    as cloud_exceptions hide CloudStorageException;
import 'package:notesapp/services/notes/notes_service.dart';

class FirebaseCloudStorage implements GenericNotesService<CloudNote> {
  static const _notesCollectionName = 'notes';
  final notes = FirebaseFirestore.instance.collection(_notesCollectionName);

  @override
  Future<void> deleteNote({
    required String noteId,
  }) async {
    try {
      await notes.doc(noteId).delete();
    } catch (e) {
      throw cloud_exceptions.CouldNotDeleteNoteException();
    }
  }

  @override
  Future<void> updateNote({
    required String noteId,
    required String text,
  }) async {
    try {
      await notes.doc(noteId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw cloud_exceptions.CouldNotUpdateNoteException();
    }
  }

  

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map(CloudNote.fromSnapshot)
          .where((note) => note.ownerUserId == ownerUserId));

  @override
  Future<Iterable<CloudNote>> getAllNotes({required String ownerId}) async {
    var whereArgs = notes.where(ownerUserIdFieldName, isEqualTo: ownerId);
    try {
      return (await whereArgs.get()).docs.map(CloudNote.fromSnapshot);
    } catch (e) {
      throw cloud_exceptions.CouldNotGetAllNotesException();
    }
  }

  @override
  Future<CloudNote> createNewNote({required String ownerId}) async {
    try {
      final document = await notes.add({
        ownerUserIdFieldName: ownerId,
        textFieldName: '',
      });
      final fetchedNote = await document.get();
      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerId,
        text: '',
      );
    } catch (e) {
      throw cloud_exceptions.CouldNotCreateNoteException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
