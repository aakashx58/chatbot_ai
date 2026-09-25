import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/layout/app_scaffold.dart';
import '../../../../core/widgets/layout/bloc_message_listener.dart';
import '../../../chat/presentation/bloc/conversations/conversations_bloc.dart';
import '../../../models/presentation/cubit/models_cubit.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocMessageListener<SettingsCubit, SettingsState>(
      message: (state) => state.message,
      child: AppScaffold(
        title: 'Settings',
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final settings = state.settings;
            return ListView(
              children: [
                SettingsSection(
                  title: 'AI',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.memory_rounded),
                      title: const Text('AI model'),
                      subtitle: Text(
                        context.select<ModelsCubit, String>(
                          (c) => c.state.activeModel?.name ?? 'Basic mode (built-in)',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRoutes.models),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.short_text_rounded),
                      title: const Text('Stream replies'),
                      subtitle: const Text('Show answers word by word as they are written'),
                      value: settings.streamingEnabled,
                      onChanged: cubit.setStreaming,
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'Appearance',
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SegmentedButton<AppThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: AppThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) => cubit.setThemeMode(selection.first),
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'Notifications',
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Reply notifications'),
                      subtitle: const Text('Alert me when a reply or download finishes in the background'),
                      value: settings.notificationsEnabled,
                      onChanged: cubit.setNotifications,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm_outlined),
                      title: const Text('Daily reminder'),
                      subtitle: const Text('A gentle nudge once a day'),
                      value: settings.dailyReminderEnabled,
                      onChanged: settings.notificationsEnabled ? cubit.setDailyReminder : null,
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'Data',
                  children: [
                    ListTile(
                      leading: Icon(Icons.delete_sweep_outlined, color: context.colors.error),
                      title: const Text('Clear chat history'),
                      subtitle: const Text('Deletes every conversation on this device'),
                      onTap: () => _clearHistory(context),
                    ),
                  ],
                ),
                const SettingsSection(
                  title: 'About',
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock_outline),
                      title: Text(AppConstants.appName),
                      subtitle: Text('Runs 100% on-device. Your chats never leave your phone.'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear all chats?',
      message: 'This permanently deletes every conversation. This cannot be undone.',
      confirmLabel: 'Clear all',
    );
    if (!confirmed || !context.mounted) return;
    context.read<ConversationsBloc>().add(const ConversationsCleared());
    context.showSnack('Chat history cleared');
  }
}
