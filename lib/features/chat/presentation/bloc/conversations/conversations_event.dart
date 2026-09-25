part of 'conversations_bloc.dart';

sealed class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object?> get props => const [];
}

final class ConversationsSubscribed extends ConversationsEvent {
  const ConversationsSubscribed();
}

final class ConversationDeleted extends ConversationsEvent {
  const ConversationDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class ConversationsCleared extends ConversationsEvent {
  const ConversationsCleared();
}
