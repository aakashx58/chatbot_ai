import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/layout/app_scaffold.dart';
import '../../../../core/widgets/layout/state_views.dart';
import '../../../models/presentation/widgets/model_banner.dart';
import '../bloc/conversations/conversations_bloc.dart';
import '../widgets/conversation_tile.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConstants.appName,
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
      header: const ModelBanner(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newChat),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New chat'),
      ),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) => switch (state) {
          ConversationsLoading() => const LoadingView(),
          ConversationsFailure(:final message) => ErrorView(
            title: 'Could not load chats',
            message: message,
            onRetry: () => context.read<ConversationsBloc>().add(const ConversationsSubscribed()),
          ),
          ConversationsLoaded(conversations: []) => EmptyStateView(
            icon: Icons.forum_outlined,
            title: 'No chats yet',
            message: 'Start a conversation. It stays private on this device.',
            action: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.newChat),
              icon: const Icon(Icons.add),
              label: const Text('Start chatting'),
            ),
          ),
          ConversationsLoaded(:final conversations) => ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationTile(
                conversation: conversation,
                onTap: () => context.push(AppRoutes.chatPath(conversation.id)),
                onDelete: () => context.read<ConversationsBloc>().add(
                  ConversationDeleted(conversation.id),
                ),
              );
            },
          ),
        },
      ),
    );
  }
}
