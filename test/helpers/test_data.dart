import 'package:offline_ai/features/chat/domain/entities/conversation.dart';
import 'package:offline_ai/features/chat/domain/entities/message.dart';

final testTime = DateTime(2026, 9, 25, 14, 30);

Message userMessage(String content, {String conversationId = 'c1', String? id}) => Message(
  id: id ?? 'u-$content',
  conversationId: conversationId,
  role: MessageRole.user,
  content: content,
  createdAt: testTime,
);

Message assistantMessage(String content, {String conversationId = 'c1', String? id}) =>
    Message(
      id: id ?? 'a-$content',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: content,
      createdAt: testTime,
    );

final testConversation = Conversation(
  id: 'c1',
  title: 'Hello',
  preview: 'Hello',
  createdAt: testTime,
  updatedAt: testTime,
);
