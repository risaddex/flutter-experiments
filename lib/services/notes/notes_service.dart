abstract class GenericNotesService<T> {

  Future<T> createNewNote({required covariant ownerId});

  Future<void> updateNote({
    required covariant noteId,
    required String text,
  });


  Future<void> deleteNote({required covariant noteId});
}
