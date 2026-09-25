/// App-wide constants. Keep magic values here so they are defined once.
abstract final class AppConstants {
  static const appName = 'Offline AI';
  static const defaultConversationTitle = 'New chat';
  static const conversationTitleMaxLength = 40;
  static const conversationPreviewMaxLength = 80;
}

abstract final class DatabaseConstants {
  static const name = 'offline_ai.db';
  static const version = 1;

  static const conversationsTable = 'conversations';
  static const messagesTable = 'messages';

  static const colId = 'id';
  static const colTitle = 'title';
  static const colPreview = 'preview';
  static const colCreatedAt = 'created_at';
  static const colUpdatedAt = 'updated_at';
  static const colConversationId = 'conversation_id';
  static const colRole = 'role';
  static const colContent = 'content';
}

abstract final class StorageKeys {
  static const themeMode = 'settings.theme_mode';
  static const streamingEnabled = 'settings.streaming_enabled';
  static const notificationsEnabled = 'settings.notifications_enabled';
  static const dailyReminderEnabled = 'settings.daily_reminder_enabled';
  static const activeModelId = 'llm.active_model_id';
}

abstract final class NotificationConstants {
  static const androidIcon = '@mipmap/ic_launcher';

  static const updatesChannelId = 'assistant_updates';
  static const updatesChannelName = 'Assistant updates';
  static const updatesChannelDescription =
      'Finished replies and model downloads while the app is in the background.';

  static const reminderChannelId = 'daily_reminder';
  static const reminderChannelName = 'Daily reminder';
  static const reminderChannelDescription = 'A gentle daily nudge to chat.';

  static const dailyReminderId = 1000;
  static const reminderTitle = 'Your offline assistant misses you';
  static const reminderBody = 'Got a question? Ask away, no internet needed.';
}
