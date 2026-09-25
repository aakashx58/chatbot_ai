import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

import '../../../../core/error/exceptions.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../chat/domain/services/ai_engine.dart';
import '../../domain/entities/llm_model.dart';
import '../../domain/repositories/model_repository.dart';
import '../datasources/gemma_model_data_source.dart';

/// Runs a real LLM fully on-device through flutter_gemma (LiteRT-LM/MediaPipe).
///
/// One model and one chat session are kept in memory. The session is reused
/// while the user continues the same conversation; switching conversations
/// (or an interrupted reply) replays recent history into a fresh context.
final class OnDeviceLlmEngine implements AiEngine {
  OnDeviceLlmEngine({required this._models, required this._gemma});

  final ModelRepository _models;
  final GemmaModelDataSource _gemma;

  static const _maxReplayMessages = 10;
  static const _systemPrompt =
      'You are Offline AI, a helpful assistant running entirely on the '
      "user's device without internet. Answer clearly and concisely.";
  static final _thinkBlock = RegExp(r'<think>[\s\S]*?(?:</think>|$)');

  LlmModel? _loadedModel;
  gemma.InferenceModel? _inference;
  gemma.InferenceChat? _chat;
  String? _syncedConversationId;
  int _syncedMessageCount = 0;

  @override
  Future<bool> isReady() async => await _models.getActiveModel() != null;

  @override
  Stream<String> generate({required List<Message> history, bool streaming = true}) async* {
    final model = await _models.getActiveModel() ??
        (throw const AiEngineException('No on-device model selected.'));
    final chat = await _step('Could not load ${model.name}', () => _ensureChat(model));
    await _step('Could not prepare the conversation', () => _syncHistory(chat, history));

    final buffer = StringBuffer();
    var completed = false;
    try {
      await for (final response in chat.generateChatResponseAsync().handleError(
        (Object e) => throw AiEngineException('Generation failed: $e'),
        test: (e) => e is! AppException,
      )) {
        // ThinkingResponse / tool calls are ignored: we only show the answer.
        if (response is! gemma.TextResponse) continue;
        buffer.write(response.token);
        final visible = _clean(buffer.toString());
        if (streaming && visible.isNotEmpty) yield visible;
      }
      completed = true;
    } finally {
      if (completed) {
        _syncedMessageCount = history.length + 1; // + the reply just generated
      } else {
        // Stopped or failed mid-reply: force a history replay next time.
        _syncedConversationId = null;
        await chat.stopGeneration().catchError((_) {});
      }
    }

    final reply = _clean(buffer.toString());
    if (reply.isEmpty) throw AiEngineException('${model.name} returned an empty reply.');
    if (!streaming) yield reply;
  }

  Future<gemma.InferenceChat> _ensureChat(LlmModel model) async {
    if (_chat != null && _loadedModel == model) return _chat!;

    await _inference?.close();
    _inference = null;
    _chat = null;
    _syncedConversationId = null;

    final inference = _inference = await _gemma.load(model);
    _loadedModel = model;
    return _chat = await inference.createChat(
      temperature: model.temperature,
      topK: model.topK,
      topP: model.topP,
      // Off: reasoning models (Qwen3) would otherwise spend the whole output
      // budget inside <think> on a phone CPU and return an empty answer.
      // flutter_gemma disables thinking for .litertlm and strips stray tags.
      isThinking: false,
      modelType: model.family.toGemma(),
      maxOutputTokens: model.maxOutputTokens,
      systemInstruction: _systemPrompt,
    );
  }

  /// Runs one engine step, wrapping native/plugin errors with context so the
  /// fallback notice and logs say *what* failed, not just that it failed.
  static Future<T> _step<T>(String context, Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AiEngineException('$context: $e');
    }
  }

  Future<void> _syncHistory(gemma.InferenceChat chat, List<Message> history) async {
    final latest = history.last;
    final prior = history.sublist(0, history.length - 1);

    final inSync = _syncedConversationId == latest.conversationId &&
        _syncedMessageCount == prior.length;
    if (!inSync) {
      await chat.clearHistory(replayHistory: _replayWindow(prior));
      _syncedConversationId = latest.conversationId;
    }
    await chat.addQueryChunk(gemma.Message.text(text: latest.content, isUser: true));
  }

  /// Last few turns, starting on a user message so the template stays valid.
  static List<gemma.Message> _replayWindow(List<Message> prior) {
    var window = prior.length > _maxReplayMessages
        ? prior.sublist(prior.length - _maxReplayMessages)
        : prior;
    window = window.skipWhile((m) => !m.isUser).toList();
    return [
      for (final m in window) gemma.Message.text(text: m.content, isUser: m.isUser),
    ];
  }

  static String _clean(String raw) => raw.replaceAll(_thinkBlock, '').trimLeft();
}
