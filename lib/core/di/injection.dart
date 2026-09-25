import 'package:get_it/get_it.dart';

import 'modules/chat_module.dart';
import 'modules/core_module.dart';
import 'modules/models_module.dart';
import 'modules/settings_module.dart';

/// Global service locator. Only the composition root (this folder), the
/// router and `App` resolve from it; everything else gets constructor injection.
final sl = GetIt.instance;

/// Wires the whole object graph. Order matters: core first, then features.
Future<void> configureDependencies() async {
  await registerCoreModule(sl);
  registerSettingsModule(sl);
  await registerModelsModule(sl);
  registerChatModule(sl);
}
