import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../cubit/models_cubit.dart';

/// Home-screen prompt to download an LLM, or live download progress.
/// Hidden once a model is active.
class ModelBanner extends StatelessWidget {
  const ModelBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ModelsCubit>().state;
    if (state.isLoading || (state.activeModel != null && !state.isDownloading)) {
      return const SizedBox.shrink();
    }

    final (title, subtitle) = state.isDownloading
        ? ('Downloading model… ${state.progress}%', 'Keep the app open until it finishes.')
        : ('Unlock smarter replies', 'Download a free on-device AI model (135–586 MB).');

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      color: context.colors.tertiaryContainer,
      child: ListTile(
        onTap: () => context.push(AppRoutes.models),
        leading: Icon(Icons.memory_rounded, color: context.colors.onTertiaryContainer),
        title: Text(title),
        subtitle: state.isDownloading
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(value: state.progress / 100),
              )
            : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
