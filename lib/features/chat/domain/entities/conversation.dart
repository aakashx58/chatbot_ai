import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;

  /// Short excerpt of the latest message, for list tiles.
  final String preview;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, title, preview, createdAt, updatedAt];
}
