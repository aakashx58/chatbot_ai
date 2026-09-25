import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../settings/domain/usecases/notify_user.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/conversation_usecases.dart';
import '../../../domain/usecases/message_usecases.dart';

part 'chat_event.dart';
part 'chat_state.dart';

final class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required this._getConversation,
    required this._createConversation,
    required this._getMessages,
    required this._saveMessage,
    required this._generateReply,
    required this._notifyUser,
  }) : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatGenerationStopped>((_, _) => _stopRequested = true);
  }

  final GetConversation _getConversation;
  final CreateConversation _createConversation;
  final GetMessages _getMessages;
  final SaveMessage _saveMessage;
  final GenerateReply _generateReply;
  final NotifyUser _notifyUser;

  bool _stopRequested = false;

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    final id = event.conversationId;
    if (id == null) return emit(state.copyWith(status: ChatStatus.ready));

    final (conversation, messages) = await (_getConversation(id), _getMessages(id)).wait;
    switch ((conversation, messages)) {
      case (Ok(data: final c), Ok(data: final m)):
        emit(state.copyWith(status: ChatStatus.ready, conversation: c, messages: m));
      case (Err(:final failure), _) || (_, Err(:final failure)):
        emit(state.copyWith(status: ChatStatus.failure, errorMessage: failure.message));
    }
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isGenerating) return;

    final conversation = await _ensureConversation(emit);
    if (conversation == null) return;

    final userMessage = await _save(emit, conversation.id, MessageRole.user, text);
    if (userMessage == null) return;

    final history = [...state.messages, userMessage];
    _stopRequested = false;
    emit(state.copyWith(messages: history, isGenerating: true, streamingReply: ''));
    // The first message renames the conversation, so refresh the title.
    await _refreshConversation(emit, conversation.id);

    try {
      await for (final partial in _generateReply(history)) {
        if (_stopRequested || emit.isDone) break;
        emit(state.copyWith(streamingReply: partial));
      }
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: const AiFailure().message));
    }
    if (emit.isDone) return;

    final reply = state.streamingReply.trim();
    emit(state.copyWith(isGenerating: false, streamingReply: ''));
    if (reply.isEmpty) return;

    // Partial replies are kept when the user presses stop.
    final assistantMessage = await _save(emit, conversation.id, MessageRole.assistant, reply);
    if (assistantMessage == null) return;
    emit(state.copyWith(messages: [...state.messages, assistantMessage]));

    await _notifyUser(
      NotifyUserParams(title: state.title, body: reply, payload: conversation.id),
    );
  }

  Future<Conversation?> _ensureConversation(Emitter<ChatState> emit) async {
    if (state.conversation case final existing?) return existing;
    return _unwrap(emit, await _createConversation(const NoParams()));
  }

  Future<Message?> _save(
    Emitter<ChatState> emit,
    String conversationId,
    MessageRole role,
    String content,
  ) async {
    final result = await _saveMessage(
      SaveMessageParams(conversationId: conversationId, role: role, content: content),
    );
    return _unwrap(emit, result);
  }

  Future<void> _refreshConversation(Emitter<ChatState> emit, String id) async {
    final updated = _unwrap(emit, await _getConversation(id));
    if (updated != null) emit(state.copyWith(conversation: updated));
  }

  /// Returns the data, or reports the failure to the UI and returns null.
  T? _unwrap<T>(Emitter<ChatState> emit, Result<T> result) => result.fold((failure) {
    emit(state.copyWith(errorMessage: failure.message, isGenerating: false));
    return null;
  }, (data) => data);
}
