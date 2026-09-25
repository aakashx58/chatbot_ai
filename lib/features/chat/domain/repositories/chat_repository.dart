import '../../../../core/error/result.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract interface class ChatRepository {
  /// Emits the full conversation list now and again after every change.
  Stream<Result<List<Conversation>>> watchConversations();

  Future<Result<Conversation>> getConversation(String id);

  Future<Result<Conversation>> createConversation();

  Future<Result<void>> deleteConversation(String id);

  Future<Result<void>> clearConversations();

  Future<Result<List<Message>>> getMessages(String conversationId);

  /// Persists a message and updates the parent conversation's preview/title.
  Future<Result<Message>> saveMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
  });

  /// Streams the assistant reply as progressively longer text.
  /// Errors are emitted as [Failure]s.
  Stream<String> generateReply({required List<Message> history, required bool streaming});
}
