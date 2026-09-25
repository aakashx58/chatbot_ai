import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/layout/app_scaffold.dart';
import '../../../../core/widgets/layout/bloc_message_listener.dart';
import '../../../../core/widgets/layout/state_views.dart';
import '../../../models/presentation/cubit/models_cubit.dart';
import '../bloc/chat/chat_bloc.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_welcome.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    final status = context.select<ChatBloc, ChatStatus>((b) => b.state.status);
    final isGenerating = context.select<ChatBloc, bool>((b) => b.state.isGenerating);

    return BlocMessageListener<ChatBloc, ChatState>(
      message: (state) => state.errorMessage,
      child: AppScaffold(
        titleWidget: BlocSelector<ChatBloc, ChatState, String>(
          selector: (state) => state.title,
          builder: (_, title) => Text(title, overflow: TextOverflow.ellipsis),
        ),
        subtitle: const _EngineLabel(),
        bottomBar: status == ChatStatus.ready
            ? ChatInputBar(
                isGenerating: isGenerating,
                onSend: (text) => bloc.add(ChatMessageSent(text)),
                onStop: () => bloc.add(const ChatGenerationStopped()),
              )
            : null,
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) => switch (state.status) {
            ChatStatus.loading => const LoadingView(),
            ChatStatus.failure => ErrorView(
              title: 'Chat unavailable',
              message: state.errorMessage ?? 'This conversation could not be opened.',
            ),
            ChatStatus.ready when state.messages.isEmpty && !state.isGenerating =>
              ChatWelcome(onSuggestionTap: (text) => bloc.add(ChatMessageSent(text))),
            ChatStatus.ready => _MessageList(state: state),
          },
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    // Slot 0 holds the in-progress reply while generating.
    final offset = state.isGenerating ? 1 : 0;

    // Reversed so the newest message sits at the bottom and stays in view.
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length + offset,
      itemBuilder: (context, index) {
        if (index < offset) {
          return MessageBubble(content: state.streamingReply, isUser: false, isStreaming: true);
        }
        final message = messages[messages.length - 1 - (index - offset)];
        return MessageBubble(
          key: ValueKey(message.id),
          content: message.content,
          isUser: message.isUser,
          time: message.createdAt,
        );
      },
    );
  }
}

/// Shows which engine answers: the downloaded LLM or the built-in basic one.
class _EngineLabel extends StatelessWidget {
  const _EngineLabel();

  @override
  Widget build(BuildContext context) {
    final modelName = context.select<ModelsCubit, String?>((c) => c.state.activeModel?.name);
    return Text(modelName == null ? 'Basic mode · offline' : '$modelName · on-device');
  }
}
