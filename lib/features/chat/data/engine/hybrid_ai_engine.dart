import 'dart:developer';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/ai_engine.dart';

/// Prefers the on-device LLM; uses the rule-based engine when no model is
/// installed, or when the LLM fails before producing any output.
final class HybridAiEngine implements AiEngine {
  const HybridAiEngine({required this._primary, required this._fallback});

  final AiEngine _primary;
  final AiEngine _fallback;

  @override
  Future<bool> isReady() async => true;

  @override
  Stream<String> generate({required List<Message> history, bool streaming = true}) async* {
    if (!await _primary.isReady()) {
      yield* _fallback.generate(history: history, streaming: streaming);
      return;
    }

    var producedOutput = false;
    try {
      await for (final chunk in _primary.generate(history: history, streaming: streaming)) {
        producedOutput = true;
        yield chunk;
      }
    } catch (e, stackTrace) {
      if (producedOutput) rethrow;
      final reason = e is AppException ? e.message : e.toString();
      // The reason is part of the message: IDE consoles often hide `error:`.
      log(
        'LLM failed, falling back: $reason',
        error: e,
        stackTrace: stackTrace,
        name: 'HybridAiEngine',
      );
      final notice = '_On-device model unavailable ($reason). Basic answer:_\n\n';
      yield* _fallback
          .generate(history: history, streaming: streaming)
          .map((text) => '$notice$text');
    }
  }
}
