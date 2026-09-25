import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_models.dart';

typedef _Db = DatabaseConstants;

abstract interface class ChatLocalDataSource {
  Future<List<ConversationModel>> getConversations();

  Future<ConversationModel?> getConversation(String id);

  Future<void> insertConversation(ConversationModel conversation);

  Future<void> deleteConversation(String id);

  Future<void> deleteAllConversations();

  Future<List<MessageModel>> getMessages(String conversationId);

  /// Inserts [message] and refreshes the parent conversation atomically.
  Future<void> insertMessage(MessageModel message, {required String preview, String? newTitle});
}

final class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  const ChatLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  sqflite.Database get _db => _database.db;

  static const _byId = '${_Db.colId} = ?';

  @override
  Future<List<ConversationModel>> getConversations() => _run(() async {
    final rows = await _db.query(
      _Db.conversationsTable,
      orderBy: '${_Db.colUpdatedAt} DESC',
    );
    return rows.map(ConversationModel.fromMap).toList();
  });

  @override
  Future<ConversationModel?> getConversation(String id) => _run(() async {
    final rows = await _db.query(
      _Db.conversationsTable,
      where: _byId,
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ConversationModel.fromMap(rows.first);
  });

  @override
  Future<void> insertConversation(ConversationModel conversation) => _run(
    () => _db.insert(_Db.conversationsTable, conversation.toMap()),
  );

  @override
  Future<void> deleteConversation(String id) =>
      _run(() => _db.delete(_Db.conversationsTable, where: _byId, whereArgs: [id]));

  @override
  Future<void> deleteAllConversations() => _run(() => _db.delete(_Db.conversationsTable));

  @override
  Future<List<MessageModel>> getMessages(String conversationId) => _run(() async {
    final rows = await _db.query(
      _Db.messagesTable,
      where: '${_Db.colConversationId} = ?',
      whereArgs: [conversationId],
      orderBy: '${_Db.colCreatedAt} ASC',
    );
    return rows.map(MessageModel.fromMap).toList();
  });

  @override
  Future<void> insertMessage(
    MessageModel message, {
    required String preview,
    String? newTitle,
  }) => _run(
    () => _db.transaction((txn) async {
      await txn.insert(_Db.messagesTable, message.toMap());
      await txn.update(
        _Db.conversationsTable,
        {
          _Db.colPreview: preview,
          _Db.colUpdatedAt: message.createdAt.millisecondsSinceEpoch,
          _Db.colTitle: ?newTitle,
        },
        where: _byId,
        whereArgs: [message.conversationId],
      );
    }),
  );

  /// Converts sqflite errors into our own [StorageException] in one place.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on sqflite.DatabaseException catch (e) {
      throw StorageException(e.toString());
    }
  }
}
