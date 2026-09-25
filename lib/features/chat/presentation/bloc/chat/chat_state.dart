part of 'chat_bloc.dart';

enum ChatStatus { loading, ready, failure }

final class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.loading,
    this.conversation,
    this.messages = const [],
    this.isGenerating = false,
    this.streamingReply = '',
    this.errorMessage,
  });

  final ChatStatus status;

  /// Null until the first message creates the conversation.
  final Conversation? conversation;
  final List<Message> messages;
  final bool isGenerating;

  /// Partial assistant reply while [isGenerating].
  final String streamingReply;

  /// One-off error for a SnackBar. Cleared on the next emit.
  final String? errorMessage;

  String get title => conversation?.title ?? AppConstants.defaultConversationTitle;

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    bool? isGenerating,
    String? streamingReply,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingReply: streamingReply ?? this.streamingReply,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversation,
    messages,
    isGenerating,
    streamingReply,
    errorMessage,
  ];
}
