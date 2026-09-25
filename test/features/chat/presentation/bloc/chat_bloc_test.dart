import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_ai/core/error/failures.dart';
import 'package:offline_ai/core/error/result.dart';
import 'package:offline_ai/core/usecase/usecase.dart';
import 'package:offline_ai/features/chat/domain/entities/message.dart';
import 'package:offline_ai/features/chat/domain/usecases/conversation_usecases.dart';
import 'package:offline_ai/features/chat/domain/usecases/message_usecases.dart';
import 'package:offline_ai/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:offline_ai/features/settings/domain/usecases/notify_user.dart';

import '../../../../helpers/test_data.dart';

class _MockGetConversation extends Mock implements GetConversation {}

class _MockCreateConversation extends Mock implements CreateConversation {}

class _MockGetMessages extends Mock implements GetMessages {}

class _MockSaveMessage extends Mock implements SaveMessage {}

class _MockGenerateReply extends Mock implements GenerateReply {}

class _MockNotifyUser extends Mock implements NotifyUser {}

void main() {
  late _MockGetConversation getConversation;
  late _MockCreateConversation createConversation;
  late _MockGetMessages getMessages;
  late _MockSaveMessage saveMessage;
  late _MockGenerateReply generateReply;
  late _MockNotifyUser notifyUser;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SaveMessageParams(conversationId: '', role: MessageRole.user, content: ''),
    );
    registerFallbackValue(const NotifyUserParams(title: '', body: ''));
  });

  setUp(() {
    getConversation = _MockGetConversation();
    createConversation = _MockCreateConversation();
    getMessages = _MockGetMessages();
    saveMessage = _MockSaveMessage();
    generateReply = _MockGenerateReply();
    notifyUser = _MockNotifyUser();

    when(() => createConversation(any())).thenAnswer((_) async => Ok(testConversation));
    when(() => getConversation(any())).thenAnswer((_) async => Ok(testConversation));
    when(() => notifyUser(any())).thenAnswer((_) async => const Ok(false));
    when(() => saveMessage(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as SaveMessageParams;
      return Ok(
        params.role == MessageRole.user
            ? userMessage(params.content)
            : assistantMessage(params.content),
      );
    });
  });

  ChatBloc buildBloc() => ChatBloc(
    getConversation: getConversation,
    createConversation: createConversation,
    getMessages: getMessages,
    saveMessage: saveMessage,
    generateReply: generateReply,
    notifyUser: notifyUser,
  );

  group('ChatStarted', () {
    blocTest<ChatBloc, ChatState>(
      'is ready and empty for a new chat',
      build: buildBloc,
      act: (bloc) => bloc.add(const ChatStarted()),
      expect: () => [const ChatState(status: ChatStatus.ready)],
    );

    blocTest<ChatBloc, ChatState>(
      'loads an existing conversation and its messages',
      setUp: () => when(() => getMessages('c1')).thenAnswer((_) async => Ok([userMessage('hi')])),
      build: buildBloc,
      act: (bloc) => bloc.add(const ChatStarted('c1')),
      expect: () => [
        ChatState(
          status: ChatStatus.ready,
          conversation: testConversation,
          messages: [userMessage('hi')],
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'fails when the conversation no longer exists',
      setUp: () {
        when(() => getConversation('gone')).thenAnswer((_) async => const Err(NotFoundFailure('gone')));
        when(() => getMessages('gone')).thenAnswer((_) async => const Ok([]));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ChatStarted('gone')),
      expect: () => [const ChatState(status: ChatStatus.failure, errorMessage: 'gone')],
    );
  });

  group('ChatMessageSent', () {
    blocTest<ChatBloc, ChatState>(
      'creates the conversation lazily, streams the reply and saves it',
      setUp: () => when(() => generateReply(any())).thenAnswer(
        (_) => Stream.fromIterable(['Hel', 'Hello!']),
      ),
      build: buildBloc,
      seed: () => const ChatState(status: ChatStatus.ready),
      act: (bloc) => bloc.add(const ChatMessageSent('  hi  ')),
      verify: (bloc) {
        verify(() => createConversation(any())).called(1);
        expect(bloc.state.isGenerating, isFalse);
        expect(bloc.state.messages.map((m) => m.content), ['hi', 'Hello!']);
        verify(() => notifyUser(any())).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emits the partial reply while streaming',
      setUp: () => when(() => generateReply(any())).thenAnswer(
        (_) => Stream.fromIterable(['Hel', 'Hello!']),
      ),
      build: buildBloc,
      seed: () => ChatState(status: ChatStatus.ready, conversation: testConversation),
      act: (bloc) => bloc.add(const ChatMessageSent('hi')),
      expect: () => containsAllInOrder([
        isA<ChatState>().having((s) => s.streamingReply, 'partial', 'Hel'),
        isA<ChatState>().having((s) => s.streamingReply, 'partial', 'Hello!'),
      ]),
    );

    blocTest<ChatBloc, ChatState>(
      'reports AI failures and stops generating',
      setUp: () => when(() => generateReply(any())).thenAnswer(
        (_) => Stream.error(const AiFailure('model crashed')),
      ),
      build: buildBloc,
      seed: () => ChatState(status: ChatStatus.ready, conversation: testConversation),
      act: (bloc) => bloc.add(const ChatMessageSent('hi')),
      expect: () => contains(
        isA<ChatState>().having((s) => s.errorMessage, 'error', 'model crashed'),
      ),
      verify: (bloc) {
        expect(bloc.state.isGenerating, isFalse);
        expect(bloc.state.messages.map((m) => m.content), ['hi']);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'ignores blank input',
      build: buildBloc,
      seed: () => const ChatState(status: ChatStatus.ready),
      act: (bloc) => bloc.add(const ChatMessageSent('   ')),
      expect: () => <ChatState>[],
    );
  });
}
