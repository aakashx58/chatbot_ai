import 'dart:math';

import '../../../../core/utils/dart_extensions.dart';
import 'chat_context.dart';

/// Strategy for one kind of user request. Handlers are tried in order; the
/// first whose [canHandle] returns true produces the reply.
abstract base class IntentHandler {
  const IntentHandler();

  bool canHandle(ChatContext context);

  String respond(ChatContext context);
}

typedef ReplyBuilder = String Function(ChatContext context);

/// Data-driven handler: matches any of [patterns] and builds a reply with
/// [reply]. Most intents are just configured instances of this class
/// (see `intent_catalog.dart`), so no per-intent subclass is needed.
final class PatternIntentHandler extends IntentHandler {
  PatternIntentHandler({required List<String> patterns, required this._reply})
    : _patterns = patterns.map((p) => RegExp(p, caseSensitive: false)).toList();

  /// Picks a random template from [replies]; `{name}` is filled in.
  factory PatternIntentHandler.canned({
    required List<String> patterns,
    required List<String> replies,
    required Random random,
  }) => PatternIntentHandler(
    patterns: patterns,
    reply: (context) => context.fill(replies.pick(random)),
  );

  final List<RegExp> _patterns;
  final ReplyBuilder _reply;

  @override
  bool canHandle(ChatContext context) => _patterns.any((p) => p.hasMatch(context.input));

  @override
  String respond(ChatContext context) => _reply(context);
}
