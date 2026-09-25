import 'dart:math';

import 'package:intl/intl.dart';

import 'intent_handler.dart';
import 'intents/conversational_intents.dart';
import 'intents/knowledge_intent.dart';
import 'intents/math_intent.dart';

/// The bot's "brain" as data. Order matters: specific intents first,
/// open-ended ones last. Add new skills here without touching the engine.
abstract final class IntentCatalog {
  static List<IntentHandler> build(Random random) => [
    const MathIntentHandler(),
    PatternIntentHandler(
      patterns: [r"\bwhat(?:'s| is)? the time\b", r'\btime is it\b', r'\bcurrent time\b'],
      reply: (c) => "It's **${DateFormat.jm().format(c.now)}** on your device.",
    ),
    PatternIntentHandler(
      patterns: [
        r"\bwhat(?:'s| is)? (?:the |today's )?date\b",
        r'\bwhat day is (?:it|today)\b',
        r"\btoday's date\b",
      ],
      reply: (c) => 'Today is **${DateFormat.yMMMMEEEEd().format(c.now)}**.',
    ),
    PatternIntentHandler(
      patterns: [r"\b(?:my name is|call me|i am called|name's)\s+[a-z]"],
      reply: (c) => c.fill('Nice to meet you, **{name}**! I\'ll remember that in this chat.'),
    ),
    PatternIntentHandler(
      patterns: [r"\bwhat(?:'s| is) my name\b", r'\bdo you (?:know|remember) my name\b', r'\bwho am i\b'],
      reply: (c) => c.userName == null
          ? "You haven't told me your name yet. Say \"my name is ...\" and I'll remember it."
          : c.fill('You told me your name is **{name}**.'),
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'^(?:hi|hello|hey|hiya|yo|howdy|greetings|good (?:morning|afternoon|evening))\b'],
      replies: [
        'Hello {name}! How can I help you today?',
        'Hi there! What would you like to chat about?',
        'Hey! Ask me anything. I work completely offline.',
      ],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'\bhow are you\b', r"\bhow(?:'s| is) it going\b", r"\bhow(?: are|'re) you doing\b"],
      replies: [
        "I'm running smoothly on your device, thanks for asking! How are you?",
        'All systems go, with no internet required. How about you?',
      ],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'\b(?:thanks|thank you|thx|ty|cheers|appreciate it)\b'],
      replies: ["You're welcome, {name}!", 'Happy to help!', 'Anytime!'],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'^(?:bye|goodbye|see you|see ya|good night|later|cya)\b'],
      replies: ['Goodbye, {name}! Your chat is saved on this device.', 'See you soon!'],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'\bwho are you\b', r'\bwhat are you\b', r"\bwhat(?:'s| is) your name\b", r'\bare you (?:a )?(?:bot|ai|human)\b'],
      replies: [
        "I'm **Offline AI**, a private assistant that runs entirely on your device. Nothing you type leaves your phone.",
      ],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'^help\b', r'\bwhat can you do\b', r'\byour (?:skills|features|abilities)\b'],
      replies: [
        'Here is what I can do offline:\n'
            '• **Maths**: "what is (12 + 8) * 3"\n'
            '• **Time & date**: "what time is it"\n'
            '• **Remember your name**: "my name is Sam"\n'
            '• **Jokes**: "tell me a joke"\n'
            '• **Tech Q&A**: Flutter, Dart, BLoC, clean architecture\n'
            '• **Wellbeing tips**: sleep, stress, focus\n'
            'Or just chat with me!',
      ],
    ),
    PatternIntentHandler.canned(
      random: random,
      patterns: [r'\bjoke\b', r'\bmake me laugh\b', r'\bsomething funny\b'],
      replies: [
        'Why do programmers prefer dark mode? Because light attracts bugs. 🐛',
        "I told my phone I needed a break. Now it won't stop showing me Kit-Kat ads.",
        'Why did the Flutter developer go broke? They used up all their state.',
        'There are 10 kinds of people: those who understand binary and those who don\'t.',
        "Why was the offline chatbot so calm? It had no connection to anyone's drama.",
      ],
    ),
    // Feelings ("I feel tired…") get an empathetic reply before facts.
    ReflectionIntentHandler(random),
    const KnowledgeIntentHandler(_knowledge),
  ];

  static const _knowledge = [
    KnowledgeEntry(
      keywords: {'offline', 'internet', 'privacy', 'private', 'data', 'online'},
      minScore: 1,
      answer: 'Everything runs on your device: replies are generated locally and chats are stored in a local SQLite database. No internet or account is needed.',
    ),
    KnowledgeEntry(
      keywords: {'flutter'},
      answer: "**Flutter** is Google's UI toolkit for building natively compiled apps for mobile, web and desktop from a single Dart codebase. Everything is a widget.",
    ),
    KnowledgeEntry(
      keywords: {'dart'},
      answer: '**Dart** is a client-optimised language with sound null safety, AOT and JIT compilation, and features like records, patterns and sealed classes.',
    ),
    KnowledgeEntry(
      keywords: {'bloc', 'cubit', 'state management'},
      answer: '**BLoC** separates business logic from UI: widgets add *events*, the bloc maps them to new *states*. A **Cubit** is a simpler variant that exposes methods instead of events.',
    ),
    KnowledgeEntry(
      keywords: {'clean architecture', 'architecture', 'layers'},
      answer: '**Clean Architecture** splits code into *presentation* (UI + blocs), *domain* (entities, use cases, repository contracts) and *data* (repository implementations, data sources). Dependencies point inward toward the domain.',
    ),
    KnowledgeEntry(
      keywords: {'dependency injection', 'get_it', 'getit', 'service locator', 'di'},
      answer: '**Dependency injection** means objects receive their collaborators instead of creating them. This app uses **get_it** as a service locator, wired once at startup.',
    ),
    KnowledgeEntry(
      keywords: {'dry', "don't repeat yourself"},
      answer: "**DRY** (Don't Repeat Yourself) means every piece of knowledge has one authoritative place, e.g. a single `guard()` that maps exceptions to failures for every repository.",
    ),
    KnowledgeEntry(
      keywords: {'sleep', 'insomnia', 'tired', 'rest'},
      answer: 'Sleep tips: keep a consistent schedule, avoid screens 30–60 min before bed, keep the room cool and dark, and limit caffeine after midday.',
    ),
    KnowledgeEntry(
      keywords: {'stress', 'anxious', 'anxiety', 'overwhelmed', 'calm', 'relax'},
      answer: 'Try box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s, repeated four times. A short walk and writing down what\'s on your mind can also help, {name}.',
    ),
    KnowledgeEntry(
      keywords: {'focus', 'productive', 'productivity', 'procrastinate', 'procrastination', 'pomodoro'},
      answer: 'Try the **Pomodoro technique**: 25 minutes of focused work, 5 minute break, and a longer break every four rounds. Pick one task and silence notifications.',
    ),
    KnowledgeEntry(
      keywords: {'water', 'hydrate', 'hydration', 'drink'},
      answer: 'A common guideline is around 2–3 litres of fluid a day, more when it\'s hot or you exercise. Pale-yellow urine is a good sign you\'re hydrated.',
    ),
    KnowledgeEntry(
      keywords: {'motivate', 'motivation', 'motivated', 'inspire', 'quote'},
      answer: '"The secret of getting ahead is getting started." (Mark Twain). Pick the smallest next step and do just that.',
    ),
  ];
}
