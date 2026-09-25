import '../../domain/entities/message.dart';

/// Everything an intent handler needs to decide on and build a reply.
final class ChatContext {
  ChatContext._({
    required this.rawInput,
    required this.input,
    required this.history,
    required this.userName,
    required this.now,
  });

  factory ChatContext.fromHistory(List<Message> history, {DateTime? now}) {
    final raw = history.lastWhere((m) => m.isUser, orElse: () => _emptyMessage).content;
    return ChatContext._(
      rawInput: raw.trim(),
      input: normalize(raw),
      history: history,
      userName: _findUserName(history),
      now: now ?? DateTime.now(),
    );
  }

  /// Original user text (trimmed).
  final String rawInput;

  /// Lower-cased, punctuation-light text used for matching.
  final String input;
  final List<Message> history;

  /// Name the user introduced earlier in this conversation, if any.
  final String? userName;
  final DateTime now;

  static final nameIntroPattern = RegExp(
    r"\b(?:my name is|call me|i am called|name's)\s+([a-z][a-z'\-]{1,24})",
    caseSensitive: false,
  );

  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[’‘`]'), "'")
      .replaceAll(RegExp(r'[!?.,;:]+(\s|$)'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Token set, used for keyword scoring.
  Set<String> get words => input.split(' ').where((w) => w.isNotEmpty).toSet();

  /// Replaces `{name}` in reply templates with the user's name.
  String fill(String template) => template.replaceAll('{name}', userName ?? 'friend');

  static String? _findUserName(List<Message> history) {
    for (final message in history.reversed.where((m) => m.isUser)) {
      final match = nameIntroPattern.firstMatch(message.content);
      if (match != null) return _capitalize(match.group(1)!);
    }
    return null;
  }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();

  static final _emptyMessage = Message(
    id: '',
    conversationId: '',
    role: MessageRole.user,
    content: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
