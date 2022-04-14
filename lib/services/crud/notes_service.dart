import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notesapp/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  // singleton pattern
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUserByEmail(email: email);
    } on CouldNotFindException<DatabaseUser> {
      return await createUser(email: email);
    }
  }

  Future<void> _cacheNotes() async {
    _notes = await getAllNotes();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUserByEmail(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindException<DatabaseUser>();
    }

    const text = '';

    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: dbUser.id,
      isSyncedWithCloud: true,
      text: text,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    await getNoteById(id: note.id);

    final updatesCount = await db.update(notesTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateException();
    }

    final updatedNote = await getNoteById(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<DatabaseNote> getNoteById({required int id}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
      where: 'id = ?',
      limit: 1,
      whereArgs: [id],
    );

    if (results.isEmpty) {
      throw CouldNotFindException<DatabaseNote>();
    }

    final note = DatabaseNote.fromRow(results.first);
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
    );

    return notes.map(DatabaseNote.fromRow).toList();
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDatabaseIsOpen();
    final deletedCount = await _getDatabaseOrThrow().delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteException<DatabaseNote>();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final deletedCount = await _getDatabaseOrThrow().delete(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteException<DatabaseUser>();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      usersTable,
      where: 'email = ?',
      limit: 1,
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw AlreadyExistsException<DatabaseUser>();
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> getUserByEmail({required String email}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final userRow = await db.query(
      usersTable,
      where: 'email = ?',
      limit: 1,
      whereArgs: [email.toLowerCase()],
    );

    if (userRow.isEmpty) {
      throw CouldNotFindException<DatabaseUser>();
    }

    return DatabaseUser.fromRow(userRow.first);
  }

  Database _getDatabaseOrThrow() {
    if (_db == null) throw DatabaseIsNotOpenException();

    return _db!;
  }

  Future<void> open() async {
    try {
      if (_db != null) throw DatabaseAlreadyOpenedException();
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create if exists
      await db.execute(createUserTable);
      await db.execute(createNoteTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    } on DatabaseAlreadyOpenedException {
      // does nothing
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureDatabaseIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {
      // does nothing
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }

    await db.close();
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Person, ID = $id, userId = $userId, isSyncWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'note';
const usersTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id" INTEGER NOT NULL,
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id" INTEGER NOT NULL,
        "user_id" INTEGER NOT NULL,
        "text" TEXT,
        "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
