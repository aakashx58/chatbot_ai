part of 'conversations_bloc.dart';

sealed class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => const [];
}

final class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

final class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded(this.conversations);

  final List<Conversation> conversations;

  @override
  List<Object?> get props => [conversations];
}

final class ConversationsFailure extends ConversationsState {
  const ConversationsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
