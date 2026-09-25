import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/usecases/conversation_usecases.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

final class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({
    required this._watchConversations,
    required this._deleteConversation,
    required this._clearConversations,
  }) : super(const ConversationsLoading()) {
    on<ConversationsSubscribed>(_onSubscribed);
    on<ConversationDeleted>((e, emit) => _mutate(emit, () => _deleteConversation(e.id)));
    on<ConversationsCleared>((_, emit) => _mutate(emit, () => _clearConversations(const NoParams())));
  }

  final WatchConversations _watchConversations;
  final DeleteConversation _deleteConversation;
  final ClearConversations _clearConversations;

  /// The repository re-emits after every write, so the list stays in sync
  /// with changes made anywhere (chat screen, settings, deletes).
  Future<void> _onSubscribed(ConversationsSubscribed event, Emitter<ConversationsState> emit) {
    return emit.forEach(
      _watchConversations(const NoParams()),
      onData: (result) => result.fold(
        (failure) => ConversationsFailure(failure.message),
        ConversationsLoaded.new,
      ),
    );
  }

  /// Mutations only report failures; success arrives through the watch stream.
  Future<void> _mutate(
    Emitter<ConversationsState> emit,
    Future<Result<void>> Function() action,
  ) async {
    final result = await action();
    if (result case Err(:final failure)) emit(ConversationsFailure(failure.message));
  }
}
