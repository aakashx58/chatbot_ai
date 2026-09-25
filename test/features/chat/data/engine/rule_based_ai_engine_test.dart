import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai/features/chat/data/engine/chat_context.dart';
import 'package:offline_ai/features/chat/data/engine/intent_catalog.dart';
import 'package:offline_ai/features/chat/data/engine/intents/conversational_intents.dart';
import 'package:offline_ai/features/chat/data/engine/rule_based_ai_engine.dart';

import '../../../../helpers/test_data.dart';

void main() {
  late RuleBasedAiEngine engine;

  setUp(() {
    final random = Random(42);
    engine = RuleBasedAiEngine(
      handlers: IntentCatalog.build(random),
      fallback: FallbackIntentHandler(random),
      thinkingDelay: Duration.zero,
      tokenDelay: Duration.zero,
      clock: () => testTime,
    );
  });

  String reply(List<String> userTurns) => engine.resolve(
    ChatContext.fromHistory([for (final t in userTurns) userMessage(t)], now: testTime),
  );

  group('RuleBasedAiEngine.resolve', () {
    test('answers arithmetic', () {
      expect(reply(['What is (12 + 8) * 3?']), contains('**60**'));
      expect(reply(['5 plus 7']), contains('**12**'));
      expect(reply(['3 x 4']), contains('**12**'));
    });

    test('answers time and date from the injected clock', () {
      expect(reply(['what time is it']), contains('2:30'));
      expect(reply(["what's the date today"]), contains('September 25, 2026'));
    });

    test('remembers the user name within a conversation', () {
      expect(reply(['my name is sam']), contains('Sam'));
      expect(reply(['my name is sam', 'what is my name?']), contains('Sam'));
    });

    test('says so when it does not know the name', () {
      expect(reply(['what is my name']), contains("haven't told me"));
    });

    test('uses the knowledge base', () {
      expect(reply(['explain bloc please']), contains('BLoC'));
      expect(reply(['does this work without internet']), contains('device'));
    });

    test('reflects feelings back', () {
      expect(reply(['i feel tired of my job']), contains('tired of your job'));
    });

    test('falls back for unknown questions', () {
      expect(reply(['Who won the 1998 chess olympiad?']), contains('offline'));
    });
  });

  group('RuleBasedAiEngine.generate', () {
    test('streams progressively longer text ending with the full reply', () async {
      final chunks = await engine.generate(history: [userMessage('2+2')]).toList();

      expect(chunks.length, greaterThan(1));
      for (var i = 1; i < chunks.length; i++) {
        expect(chunks[i].startsWith(chunks[i - 1]), isTrue);
      }
      expect(chunks.last, contains('**4**'));
    });

    test('emits a single event when streaming is off', () async {
      final chunks = await engine
          .generate(history: [userMessage('2+2')], streaming: false)
          .toList();

      expect(chunks, hasLength(1));
    });
  });
}
