import 'package:flutter/material.dart';

/// Text field with a send button that turns into a stop button while the
/// assistant is replying.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    super.key,
  });

  final bool isGenerating;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(hintText: 'Message Offline AI…'),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => widget.isGenerating
                  ? IconButton.filledTonal(
                      tooltip: 'Stop',
                      onPressed: widget.onStop,
                      icon: const Icon(Icons.stop_rounded),
                    )
                  : IconButton.filled(
                      tooltip: 'Send',
                      onPressed: value.text.trim().isEmpty ? null : _submit,
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
