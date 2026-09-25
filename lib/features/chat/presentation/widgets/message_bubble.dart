import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/dart_extensions.dart';
import 'typing_indicator.dart';

/// One chat bubble. Also used for the in-progress (streaming) reply.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.content,
    required this.isUser,
    this.time,
    this.isStreaming = false,
    super.key,
  });

  final String content;
  final bool isUser;
  final DateTime? time;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = isUser ? colors.primary : colors.surfaceContainerHigh;
    final foreground = isUser ? colors.onPrimary : colors.onSurface;
    const radius = Radius.circular(20);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: GestureDetector(
          onLongPress: content.isEmpty ? null : () => _copy(context),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: isUser ? radius : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : radius,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (content.isEmpty && isStreaming)
                  const TypingIndicator()
                else
                  MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet.fromTheme(context.theme).copyWith(
                      p: context.textTheme.bodyLarge?.copyWith(color: foreground),
                      listBullet: context.textTheme.bodyLarge?.copyWith(color: foreground),
                      code: context.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    time!.toRelativeLabel(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) context.showSnack('Copied to clipboard');
  }
}
