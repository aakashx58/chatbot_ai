import 'dart:math';

import '../../../../../core/utils/dart_extensions.dart';
import '../chat_context.dart';
import '../intent_handler.dart';

/// ELIZA-style reflection: "I feel tired" -> "Why do you feel tired?".
final class ReflectionIntentHandler extends IntentHandler {
  ReflectionIntentHandler(this._random);

  final Random _random;

  static final _rules = <RegExp, List<String>>{
    RegExp(r"\bi(?: am|'m) feeling (.+)"): [
      'Why do you think you are feeling {0}?',
      'How long have you been feeling {0}?',
    ],
    RegExp(r'\bi feel (.+)'): [
      'What makes you feel {0}?',
      'Do you often feel {0}?',
    ],
    RegExp(r'\bi need (.+)'): [
      'Why do you need {0}?',
      'Would getting {0} really help you?',
    ],
    RegExp(r'\bi want (.+)'): [
      'What would it mean to you if you got {0}?',
      'Why do you want {0}?',
    ],
    RegExp(r"\bi can't (.+)"): [
      'What makes you think you can\'t {0}?',
      'Have you tried breaking it into smaller steps?',
    ],
    RegExp(r'\bi think (.+)'): [
      'What makes you think {0}?',
      'Do you really think so?',
    ],
  };

  static const _pronouns = {
    'i': 'you',
    'me': 'you',
    'my': 'your',
    'am': 'are',
    "i'm": "you're",
    'myself': 'yourself',
    'you': 'I',
    'your': 'my',
  };

  @override
  bool canHandle(ChatContext context) => _rules.keys.any((r) => r.hasMatch(context.input));

  @override
  String respond(ChatContext context) {
    final MapEntry(key: rule, value: templates) =
        _rules.entries.firstWhere((e) => e.key.hasMatch(context.input));
    final fragment = _reflect(rule.firstMatch(context.input)!.group(1)!);
    return templates.pick(_random).replaceAll('{0}', fragment);
  }

  static String _reflect(String fragment) =>
      fragment.split(' ').map((w) => _pronouns[w] ?? w).join(' ');
}

/// Always matches; used when nothing else does.
final class FallbackIntentHandler extends IntentHandler {
  const FallbackIntentHandler(this._random);

  final Random _random;

  static final _questionStart = RegExp(r'^(what|who|where|when|why|how|which|can|could|is|are|do|does)\b');

  static const _unknownQuestion = [
    "Good question! I run fully offline with a compact knowledge base, so I don't have an answer for that one yet. Type **help** to see what I can do.",
    "Hmm, that's outside what I know offline. I'm best at small talk, maths, dates and a few tech topics. Try **help**.",
  ];
  static const _statement = [
    'Interesting, tell me more.',
    'I see. How does that make you feel?',
    'Got it. What would you like to do next?',
    "I'm listening. Could you expand on that?",
  ];

  @override
  bool canHandle(ChatContext context) => true;

  @override
  String respond(ChatContext context) {
    final isQuestion = context.rawInput.endsWith('?') || _questionStart.hasMatch(context.input);
    return (isQuestion ? _unknownQuestion : _statement).pick(_random);
  }
}
