import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class WatchConversations implements StreamUseCase<Result<List<Conversation>>, NoParams> {
  const WatchConversations(this._repository);

  final ChatRepository _repository;

  @override
  Stream<Result<List<Conversation>>> call(NoParams params) =>
      _repository.watchConversations();
}

class GetConversation implements UseCase<Conversation, String> {
  const GetConversation(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<Conversation>> call(String id) => _repository.getConversation(id);
}

class CreateConversation implements UseCase<Conversation, NoParams> {
  const CreateConversation(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<Conversation>> call(NoParams params) => _repository.createConversation();
}

class DeleteConversation implements UseCase<void, String> {
  const DeleteConversation(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteConversation(id);
}

class ClearConversations implements UseCase<void, NoParams> {
  const ClearConversations(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.clearConversations();
}
