import '../chat_context.dart';
import '../expression_evaluator.dart';
import '../intent_handler.dart';

/// Answers arithmetic like "what is 12 * (3 + 4)" or "5 plus 7 squared".
final class MathIntentHandler extends IntentHandler {
  const MathIntentHandler([this._evaluator = const ExpressionEvaluator()]);

  final ExpressionEvaluator _evaluator;

  static final _prefix = RegExp(
    r"^(?:what's|whats|what is|calculate|compute|solve|evaluate|how much is)\s*",
  );
  static const _wordOperators = {
    'to the power of': '^',
    'multiplied by': '*',
    'divided by': '/',
    'squared': '^2',
    'cubed': '^3',
    'plus': '+',
    'minus': '-',
    'times': '*',
    'mod': '%',
    '×': '*',
    '÷': '/',
  };
  static final _allowed = RegExp(r'^[\d\s.+\-*/%^()]+$');
  static final _hasOperation = RegExp(r'\d\s*[-+*/%^]\s*[\d(.-]');
  static final _letterX = RegExp(r'(?<=\d)\s*x\s*(?=\d)');

  @override
  bool canHandle(ChatContext context) => _extract(context.input) != null;

  @override
  String respond(ChatContext context) {
    final expression = _extract(context.input)!;
    final value = _evaluator.tryEvaluate(expression);
    if (value == null || value.isNaN || value.isInfinite) {
      return "I couldn't compute `$expression`. Check for division by zero or unbalanced brackets.";
    }
    return '$expression = **${_format(value)}**';
  }

  String? _extract(String input) {
    var text = input.replaceFirst(_prefix, '').replaceAll('=', '').trim();
    for (final MapEntry(:key, :value) in _wordOperators.entries) {
      text = text.replaceAll(key, value);
    }
    text = text.replaceAll(_letterX, '*').replaceAll(RegExp(r'\s+'), ' ').trim();
    return _allowed.hasMatch(text) && _hasOperation.hasMatch(text) ? text : null;
  }

  static String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
