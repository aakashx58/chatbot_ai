import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/bloc/chat/chat_bloc.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/models/presentation/pages/models_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../di/injection.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/layout/app_scaffold.dart';
import 'app_routes.dart';

/// Declarative route table. Route-scoped blocs are created here so pages stay
/// free of DI lookups.
final class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const ConversationsPage()),
      GoRoute(path: AppRoutes.newChat, builder: (_, _) => _chat(null)),
      GoRoute(
        path: AppRoutes.chat,
        builder: (_, state) => _chat(state.pathParameters['id']),
      ),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: AppRoutes.models, builder: (_, _) => const ModelsPage()),
    ],
    errorBuilder: (_, state) => AppScaffold(
      body: EmptyStateView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: state.uri.toString(),
      ),
    ),
  );

  static Widget _chat(String? conversationId) => BlocProvider(
    // Keyed so opening a different chat always gets a fresh bloc.
    key: ValueKey(conversationId),
    create: (_) => sl<ChatBloc>()..add(ChatStarted(conversationId)),
    child: const ChatPage(),
  );
}
