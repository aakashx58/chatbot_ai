import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_view.dart';

/// Empty-chat placeholder with tappable starter prompts.
class ChatWelcome extends StatelessWidget {
  const ChatWelcome({required this.onSuggestionTap, super.key});

  final ValueChanged<String> onSuggestionTap;

  static const _suggestions = [
    'What can you do?',
    'Tell me a joke',
    'What is (12 + 8) * 3?',
    'Explain BLoC in Flutter',
    'Tips to focus better',
  ];

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.auto_awesome_rounded,
      title: 'How can I help?',
      message: 'Everything stays on your device. No internet needed.',
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final suggestion in _suggestions)
            ActionChip(label: Text(suggestion), onPressed: () => onSuggestionTap(suggestion)),
        ],
      ),
    );
  }
}
