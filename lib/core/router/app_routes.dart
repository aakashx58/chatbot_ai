/// Route paths in one place so navigation never uses string literals.
abstract final class AppRoutes {
  static const home = '/';
  static const newChat = '/chat';
  static const chat = '/chat/:id';
  static const settings = '/settings';
  static const models = '/models';

  static String chatPath(String id) => '/chat/$id';
}
