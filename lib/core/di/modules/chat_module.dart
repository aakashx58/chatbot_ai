import 'dart:math';

import 'package:get_it/get_it.dart';

import '../../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../../features/chat/data/engine/hybrid_ai_engine.dart';
import '../../../features/chat/data/engine/intent_catalog.dart';
import '../../../features/chat/data/engine/intents/conversational_intents.dart';
import '../../../features/chat/data/engine/rule_based_ai_engine.dart';
import '../../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../../features/chat/domain/repositories/chat_repository.dart';
import '../../../features/chat/domain/services/ai_engine.dart';
import '../../../features/chat/domain/usecases/conversation_usecases.dart';
import '../../../features/chat/domain/usecases/message_usecases.dart';
import '../../../features/chat/presentation/bloc/chat/chat_bloc.dart';
import '../../../features/chat/presentation/bloc/conversations/conversations_bloc.dart';
import '../../../features/models/data/engine/on_device_llm_engine.dart';

void registerChatModule(GetIt sl) {
  final random = Random();

  sl
    // Data
    ..registerLazySingleton<ChatLocalDataSource>(() => ChatLocalDataSourceImpl(sl()))
    ..registerLazySingleton(
      () => RuleBasedAiEngine(
        handlers: IntentCatalog.build(random),
        fallback: FallbackIntentHandler(random),
      ),
    )
    // Swap this registration to change how replies are produced.
    ..registerLazySingleton<AiEngine>(
      () => HybridAiEngine(
        primary: sl<OnDeviceLlmEngine>(),
        fallback: sl<RuleBasedAiEngine>(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(local: sl(), engine: sl(), uuid: sl()),
    )
    // Domain
    ..registerLazySingleton(() => WatchConversations(sl()))
    ..registerLazySingleton(() => GetConversation(sl()))
    ..registerLazySingleton(() => CreateConversation(sl()))
    ..registerLazySingleton(() => DeleteConversation(sl()))
    ..registerLazySingleton(() => ClearConversations(sl()))
    ..registerLazySingleton(() => GetMessages(sl()))
    ..registerLazySingleton(() => SaveMessage(sl()))
    ..registerLazySingleton(() => GenerateReply(sl(), sl()))
    // Presentation
    ..registerFactory(
      () => ConversationsBloc(
        watchConversations: sl(),
        deleteConversation: sl(),
        clearConversations: sl(),
      ),
    )
    ..registerFactory(
      () => ChatBloc(
        getConversation: sl(),
        createConversation: sl(),
        getMessages: sl(),
        saveMessage: sl(),
        generateReply: sl(),
        notifyUser: sl(),
      ),
    );
}
