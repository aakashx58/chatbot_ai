import '../chat_context.dart';
import '../intent_handler.dart';

/// A small offline fact. Multi-word keywords match as phrases.
final class KnowledgeEntry {
  const KnowledgeEntry({required this.keywords, required this.answer, this.minScore = 1});

  final Set<String> keywords;
  final String answer;

  /// How many keywords must appear before this entry is considered a match.
  final int minScore;

  int score(ChatContext context) => keywords
      .where((k) => k.contains(' ') ? context.input.contains(k) : context.words.contains(k))
      .length;
}

/// Retrieval step: returns the best-scoring [KnowledgeEntry] for the input.
final class KnowledgeIntentHandler extends IntentHandler {
  const KnowledgeIntentHandler(this._entries);

  final List<KnowledgeEntry> _entries;

  @override
  bool canHandle(ChatContext context) => _bestMatch(context) != null;

  @override
  String respond(ChatContext context) => context.fill(_bestMatch(context)!.answer);

  KnowledgeEntry? _bestMatch(ChatContext context) {
    KnowledgeEntry? best;
    var bestScore = 0;
    for (final entry in _entries) {
      final score = entry.score(context);
      if (score >= entry.minScore && score > bestScore) {
        best = entry;
        bestScore = score;
      }
    }
    return best;
  }
}
