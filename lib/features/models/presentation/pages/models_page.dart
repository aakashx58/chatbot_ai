import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/layout/app_scaffold.dart';
import '../../../../core/widgets/layout/bloc_message_listener.dart';
import '../../../../core/widgets/layout/state_views.dart';
import '../cubit/models_cubit.dart';
import '../widgets/model_tile.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ModelsCubit>();
    return BlocMessageListener<ModelsCubit, ModelsState>(
      message: (state) => state.message,
      child: AppScaffold(
        title: 'AI models',
        body: BlocBuilder<ModelsCubit, ModelsState>(
          builder: (context, state) {
            if (state.isLoading) return const LoadingView();
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Models download once over the internet, then run fully '
                    'offline on your phone. Bigger models give better answers '
                    'but need more storage and memory.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.bolt_outlined),
                    title: const Text('Basic mode (built-in)'),
                    subtitle: const Text('Instant rule-based replies. No download.'),
                    trailing: state.activeModelId == null
                        ? const Icon(Icons.check_circle)
                        : TextButton(
                            onPressed: () => cubit.select(null),
                            child: const Text('Use'),
                          ),
                  ),
                ),
                for (final model in state.catalog)
                  ModelTile(
                    model: model,
                    status: state.statusOf(model),
                    isActive: state.activeModelId == model.id,
                    progress: state.progress,
                    canDownload: !state.isDownloading,
                    onDownload: () => cubit.download(model),
                    onCancel: cubit.cancelDownload,
                    onSelect: () => cubit.select(model),
                    onDelete: () async {
                      final confirmed = await showConfirmDialog(
                        context,
                        title: 'Delete ${model.name}?',
                        message: 'Frees ${model.sizeLabel}. You can download it again later.',
                      );
                      if (confirmed) await cubit.delete(model);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
