import 'package:flutter/material.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/dart_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/conversation.dart';

/// Swipe-to-delete list tile for a conversation.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: context.colors.errorContainer,
        child: Icon(Icons.delete_outline, color: context.colors.onErrorContainer),
      ),
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'Delete chat?',
        message: '"${conversation.title}" will be permanently removed.',
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: context.colors.secondaryContainer,
          child: Icon(Icons.chat_bubble_outline, color: context.colors.onSecondaryContainer),
        ),
        title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: conversation.preview.isEmpty
            ? null
            : Text(conversation.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          conversation.updatedAt.toRelativeLabel(),
          style: context.textTheme.labelSmall,
        ),
      ),
    );
  }
}
