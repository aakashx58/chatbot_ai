import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

typedef _Db = DatabaseConstants;

/// DB row <-> entity mapping lives here, keeping entities persistence-free.
final class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.preview,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromMap(Map<String, Object?> map) => ConversationModel(
    id: map[_Db.colId]! as String,
    title: map[_Db.colTitle]! as String,
    preview: map[_Db.colPreview] as String? ?? '',
    createdAt: _dateFrom(map[_Db.colCreatedAt]),
    updatedAt: _dateFrom(map[_Db.colUpdatedAt]),
  );

  Map<String, Object?> toMap() => {
    _Db.colId: id,
    _Db.colTitle: title,
    _Db.colPreview: preview,
    _Db.colCreatedAt: createdAt.millisecondsSinceEpoch,
    _Db.colUpdatedAt: updatedAt.millisecondsSinceEpoch,
  };
}

final class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    required super.createdAt,
  });

  factory MessageModel.fromMap(Map<String, Object?> map) => MessageModel(
    id: map[_Db.colId]! as String,
    conversationId: map[_Db.colConversationId]! as String,
    role: MessageRole.values.byName(map[_Db.colRole]! as String),
    content: map[_Db.colContent]! as String,
    createdAt: _dateFrom(map[_Db.colCreatedAt]),
  );

  Map<String, Object?> toMap() => {
    _Db.colId: id,
    _Db.colConversationId: conversationId,
    _Db.colRole: role.name,
    _Db.colContent: content,
    _Db.colCreatedAt: createdAt.millisecondsSinceEpoch,
  };
}

DateTime _dateFrom(Object? millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis! as int);
