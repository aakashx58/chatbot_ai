import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/dart_extensions.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/services/ai_engine.dart';
import '../datasources/chat_local_data_source.dart';
import '../models/chat_models.dart';

final class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this._local,
    required this._engine,
    required this._uuid,
    this._clock = DateTime.now,
  });

  final ChatLocalDataSource _local;
  final AiEngine _engine;
  final Uuid _uuid;
  final DateTime Function() _clock;

  /// Pinged after every write so watchers re-query (single source of truth).
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<Result<List<Conversation>>> watchConversations() async* {
    yield await guard(_local.getConversations);
    await for (final _ in _changes.stream) {
      yield await guard(_local.getConversations);
    }
  }

  @override
  Future<Result<Conversation>> getConversation(String id) => guard(() async {
    return await _local.getConversation(id) ??
        (throw const NotFoundException('This conversation no longer exists.'));
  });

  @override
  Future<Result<Conversation>> createConversation() => _write(() async {
    final now = _clock();
    final conversation = ConversationModel(
      id: _uuid.v4(),
      title: AppConstants.defaultConversationTitle,
      preview: '',
      createdAt: now,
      updatedAt: now,
    );
    await _local.insertConversation(conversation);
    return conversation;
  });

  @override
  Future<Result<void>> deleteConversation(String id) =>
      _write(() => _local.deleteConversation(id));

  @override
  Future<Result<void>> clearConversations() => _write(_local.deleteAllConversations);

  @override
  Future<Result<List<Message>>> getMessages(String conversationId) =>
      guard(() => _local.getMessages(conversationId));

  @override
  Future<Result<Message>> saveMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
  }) => _write(() async {
    final conversation = await _local.getConversation(conversationId) ??
        (throw const NotFoundException('This conversation no longer exists.'));
    final message = MessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: _clock(),
    );
    // The first user message names the conversation.
    final shouldRename = role == MessageRole.user &&
        conversation.title == AppConstants.defaultConversationTitle;
    await _local.insertMessage(
      message,
      preview: content.truncate(AppConstants.conversationPreviewMaxLength),
      newTitle: shouldRename ? content.truncate(AppConstants.conversationTitleMaxLength) : null,
    );
    return message;
  });

  @override
  Stream<String> generateReply({required List<Message> history, required bool streaming}) =>
      _engine
          .generate(history: history, streaming: streaming)
          .handleError((Object e, StackTrace st) => throw mapExceptionToFailure(e));

  /// [guard] + change notification for every mutating operation (DRY).
  Future<Result<T>> _write<T>(Future<T> Function() action) async {
    final result = await guard(action);
    if (result.isOk) _changes.add(null);
    return result;
  }
}
