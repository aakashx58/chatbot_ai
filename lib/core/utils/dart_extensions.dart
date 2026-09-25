import 'dart:math';

import 'package:intl/intl.dart';

/// Pure-Dart extensions: safe to use from domain and data layers.
extension StringX on String {
  /// Collapses whitespace and cuts to [maxLength] with an ellipsis.
  String truncate(int maxLength) {
    final singleLine = trim().replaceAll(RegExp(r'\s+'), ' ');
    if (singleLine.length <= maxLength) return singleLine;
    return '${singleLine.substring(0, maxLength).trimRight()}…';
  }
}

extension ListPickX<T> on List<T> {
  T pick(Random random) => this[random.nextInt(length)];
}

extension DateTimeX on DateTime {
  /// "2:05 PM" for today, "Mon" within a week, otherwise "Mar 3".
  String toRelativeLabel([DateTime? now]) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    if (!isBefore(today)) return DateFormat.jm().format(this);
    if (today.difference(this).inDays < 6) return DateFormat.E().format(this);
    return DateFormat.MMMd().format(this);
  }
}
