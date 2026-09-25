import 'package:flutter/material.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../domain/entities/llm_model.dart';

/// Card for one downloadable model with the action that fits its state.
class ModelTile extends StatelessWidget {
  const ModelTile({
    required this.model,
    required this.status,
    required this.isActive,
    required this.progress,
    required this.canDownload,
    required this.onDownload,
    required this.onCancel,
    required this.onSelect,
    required this.onDelete,
    super.key,
  });

  final LlmModel model;
  final ModelInstallStatus status;
  final bool isActive;
  final int progress;

  /// False while another model is downloading.
  final bool canDownload;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: context.colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(model.name, style: context.textTheme.titleMedium)),
                if (model.recommended) const _Tag('Recommended'),
                if (isActive) const _Tag('In use'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${model.sizeLabel} · ${model.description}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ..._actions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) => switch (status) {
    ModelInstallStatus.downloading => [
      LinearProgressIndicator(value: progress == 0 ? null : progress / 100),
      const SizedBox(height: 8),
      Row(
        children: [
          Text('$progress%', style: context.textTheme.labelMedium),
          const Spacer(),
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ),
    ],
    ModelInstallStatus.installed => [
      Row(
        children: [
          if (!isActive)
            FilledButton.tonal(onPressed: onSelect, child: const Text('Use this model')),
          const Spacer(),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ],
    ModelInstallStatus.notInstalled => [
      FilledButton.icon(
        onPressed: canDownload ? onDownload : null,
        icon: const Icon(Icons.download_rounded),
        label: Text('Download (${model.sizeLabel})'),
      ),
    ],
  };
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: context.colors.onPrimaryContainer),
      ),
    );
  }
}
