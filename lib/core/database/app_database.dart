import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

typedef _Db = DatabaseConstants;

/// Owns the on-device SQLite database used for chat history.
final class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static Future<AppDatabase> open() async {
    final path = join(await getDatabasesPath(), DatabaseConstants.name);
    final db = await openDatabase(
      path,
      version: DatabaseConstants.version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE ${_Db.conversationsTable} (
          ${_Db.colId} TEXT PRIMARY KEY,
          ${_Db.colTitle} TEXT NOT NULL,
          ${_Db.colPreview} TEXT NOT NULL DEFAULT '',
          ${_Db.colCreatedAt} INTEGER NOT NULL,
          ${_Db.colUpdatedAt} INTEGER NOT NULL
        )
      ''')
      ..execute('''
        CREATE TABLE ${_Db.messagesTable} (
          ${_Db.colId} TEXT PRIMARY KEY,
          ${_Db.colConversationId} TEXT NOT NULL
            REFERENCES ${_Db.conversationsTable}(${_Db.colId}) ON DELETE CASCADE,
          ${_Db.colRole} TEXT NOT NULL,
          ${_Db.colContent} TEXT NOT NULL,
          ${_Db.colCreatedAt} INTEGER NOT NULL
        )
      ''')
      ..execute(
        'CREATE INDEX idx_messages_conversation '
        'ON ${_Db.messagesTable}(${_Db.colConversationId}, ${_Db.colCreatedAt})',
      );
    await batch.commit(noResult: true);
  }

  Future<void> close() => db.close();
}
