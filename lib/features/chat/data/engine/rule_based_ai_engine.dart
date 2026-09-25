import '../../domain/entities/message.dart';
import '../../domain/services/ai_engine.dart';
import 'chat_context.dart';
import 'intent_handler.dart';

/// Zero-download engine: routes the latest message through an ordered list of
/// [IntentHandler]s, then "types" the reply out token by token.
final class RuleBasedAiEngine implements AiEngine {
  const RuleBasedAiEngine({
    required this._handlers,
    required this._fallback,
    this._thinkingDelay = const Duration(milliseconds: 500),
    this._tokenDelay = const Duration(milliseconds: 35),
    this._clock = DateTime.now,
  });

  final List<IntentHandler> _handlers;
  final IntentHandler _fallback;
  final Duration _thinkingDelay;
  final Duration _tokenDelay;
  final DateTime Function() _clock;

  static final _token = RegExp(r'\S+\s*');

  @override
  Future<bool> isReady() async => true;

  @override
  Stream<String> generate({required List<Message> history, bool streaming = true}) async* {
    final reply = resolve(ChatContext.fromHistory(history, now: _clock()));
    await Future<void>.delayed(_thinkingDelay);

    if (!streaming) {
      yield reply;
      return;
    }
    final buffer = StringBuffer();
    for (final match in _token.allMatches(reply)) {
      buffer.write(match.group(0));
      yield buffer.toString();
      await Future<void>.delayed(_tokenDelay);
    }
  }

  /// Synchronous routing step, exposed for unit tests.
  String resolve(ChatContext context) {
    if (context.input.isEmpty) return 'Say something and I\'ll do my best to help!';
    final handler = _handlers.firstWhere((h) => h.canHandle(context), orElse: () => _fallback);
    return handler.respond(context);
  }
}
