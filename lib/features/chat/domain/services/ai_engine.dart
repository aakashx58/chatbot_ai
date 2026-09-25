import '../entities/message.dart';

/// Contract for any on-device reply generator.
///
/// Implementations:
/// * `OnDeviceLlmEngine` – a real LLM (Qwen / SmolLM …) via flutter_gemma.
/// * `RuleBasedAiEngine` – instant, zero-download intent engine.
/// * `HybridAiEngine`   – uses the LLM when a model is installed, otherwise
///   (or on failure) falls back to the rule-based engine.
abstract interface class AiEngine {
  /// Whether this engine can answer right now (e.g. a model is installed).
  Future<bool> isReady();

  /// [history] is oldest-first and ends with the latest user message.
  /// Emits progressively longer text; the last event is the full reply.
  Stream<String> generate({required List<Message> history, bool streaming = true});
}
