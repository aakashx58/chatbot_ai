import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages implements UseCase<List<Message>, String> {
  const GetMessages(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<List<Message>>> call(String conversationId) =>
      _repository.getMessages(conversationId);
}

final class SaveMessageParams extends Equatable {
  const SaveMessageParams({
    required this.conversationId,
    required this.role,
    required this.content,
  });

  final String conversationId;
  final MessageRole role;
  final String content;

  @override
  List<Object?> get props => [conversationId, role, content];
}

/// Used for both user and assistant messages (one persistence path).
class SaveMessage implements UseCase<Message, SaveMessageParams> {
  const SaveMessage(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<Message>> call(SaveMessageParams params) => _repository.saveMessage(
    conversationId: params.conversationId,
    role: params.role,
    content: params.content,
  );
}

/// Streams the assistant's reply, honouring the user's streaming preference.
class GenerateReply implements StreamUseCase<String, List<Message>> {
  const GenerateReply(this._chatRepository, this._settingsRepository);

  final ChatRepository _chatRepository;
  final SettingsRepository _settingsRepository;

  @override
  Stream<String> call(List<Message> history) async* {
    final settings = (await _settingsRepository.getSettings()).dataOrNull ??
        AppSettings.defaults;
    yield* _chatRepository.generateReply(
      history: history,
      streaming: settings.streamingEnabled,
    );
  }
}
