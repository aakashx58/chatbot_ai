import 'dart:math' as math;

/// Small recursive-descent evaluator for arithmetic:
/// `+ - * / % ^`, parentheses, unary minus and decimals.
///
/// Grammar:
///   expr   := term (('+' | '-') term)*
///   term   := factor (('*' | '/' | '%') factor)*
///   factor := unary ('^' factor)?
///   unary  := '-' unary | primary
///   primary:= number | '(' expr ')'
final class ExpressionEvaluator {
  const ExpressionEvaluator();

  /// Returns `null` when [source] is not a valid expression.
  double? tryEvaluate(String source) {
    try {
      return _Parser(source).parse();
    } on FormatException {
      return null;
    }
  }
}

final class _Parser {
  _Parser(this._src);

  final String _src;
  int _pos = 0;

  double parse() {
    final value = _expr();
    _skipWhitespace();
    if (_pos != _src.length) throw FormatException('Unexpected "${_src[_pos]}"');
    return value;
  }

  double _expr() {
    var value = _term();
    while (_peekAny('+-')) {
      value = _next() == '+' ? value + _term() : value - _term();
    }
    return value;
  }

  double _term() {
    var value = _factor();
    while (_peekAny('*/%')) {
      final op = _next();
      final rhs = _factor();
      if (op != '*' && rhs == 0) throw const FormatException('Division by zero');
      value = switch (op) {
        '*' => value * rhs,
        '/' => value / rhs,
        _ => value % rhs,
      };
    }
    return value;
  }

  double _factor() {
    final base = _unary();
    if (_peekAny('^')) {
      _next();
      return math.pow(base, _factor()).toDouble(); // right-associative
    }
    return base;
  }

  double _unary() {
    if (_peekAny('-')) {
      _next();
      return -_unary();
    }
    return _primary();
  }

  double _primary() {
    if (_peekAny('(')) {
      _next();
      final value = _expr();
      if (!_peekAny(')')) throw const FormatException('Missing ")"');
      _next();
      return value;
    }
    _skipWhitespace();
    final start = _pos;
    while (_pos < _src.length && '0123456789.'.contains(_src[_pos])) {
      _pos++;
    }
    return double.tryParse(_src.substring(start, _pos)) ??
        (throw FormatException('Expected number at $start'));
  }

  /// Whitespace separates tokens but never joins them ("1 2" is invalid).
  bool _peekAny(String chars) {
    _skipWhitespace();
    return _pos < _src.length && chars.contains(_src[_pos]);
  }

  void _skipWhitespace() {
    while (_pos < _src.length && _src[_pos] == ' ') {
      _pos++;
    }
  }

  String _next() => _src[_pos++];
}
