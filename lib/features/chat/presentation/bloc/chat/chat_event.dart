part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => const [];
}

/// Opens an existing conversation, or a blank one when [conversationId] is null
/// (it is created lazily on the first message, so empty chats aren't saved).
final class ChatStarted extends ChatEvent {
  const ChatStarted([this.conversationId]);

  final String? conversationId;

  @override
  List<Object?> get props => [conversationId];
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class ChatGenerationStopped extends ChatEvent {
  const ChatGenerationStopped();
}
