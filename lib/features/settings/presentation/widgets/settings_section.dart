import 'package:flutter/material.dart';

import '../../../../core/utils/context_extensions.dart';

/// Titled group of settings tiles.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.primary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
