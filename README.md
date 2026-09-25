# Offline AI

A private chatbot that runs **entirely on the device**. It uses a real on-device LLM (Qwen / SmolLM, run through
[flutter_gemma](https://pub.dev/packages/flutter_gemma) on LiteRT-LM or MediaPipe). A built-in rule-based engine
answers instantly when no model is installed. The only network access is the one-time model download.

## Features

- Chat with streamed replies, a stop button, Markdown rendering and copy on long-press
- On-device LLMs: Qwen3 0.6B, Qwen 2.5 0.5B, SmolLM 135M (public, no token needed); download, switch or delete them in-app
- Built-in basic mode that needs no download: maths, time and date, name memory, jokes, a small knowledge base, empathetic replies
- Chat history in SQLite, with swipe-to-delete and clear-all
- Settings in SharedPreferences: theme, streaming, notifications, daily reminder
- Local notifications: a finished reply or model download while the app is in the background, plus an optional daily reminder. Tapping a notification opens the chat.

## Architecture

Feature-first **Clean Architecture**. Dependencies point inward: `presentation → domain ← data`.

```
lib/
├── main.dart / app.dart        # bootstrap, app-wide blocs, theme, notification deep links
├── core/                       # shared, feature-agnostic
│   ├── di/                     # get_it composition root, one module per feature
│   ├── error/                  # Failure, AppException, Result<T>, guard()
│   ├── usecase/                # UseCase / StreamUseCase contracts
│   ├── router/                 # go_router table + AppRoutes constants
│   ├── storage/                # KeyValueStorage over SharedPreferences
│   ├── database/               # SQLite schema
│   ├── notifications/          # NotificationService over flutter_local_notifications
│   ├── widgets/layout/         # AppScaffold, BlocMessageListener, Loading/ErrorView
│   └── theme/ utils/ constants/ lifecycle/ bloc/
└── features/
    ├── chat/                   # conversations, messages, reply engines
    ├── models/                 # on-device LLM catalog, download, inference engine
    └── settings/               # preferences + NotifyUser gate
```

Each feature has three layers:

| Layer          | Contains                                              | Depends on         |
|----------------|-------------------------------------------------------|--------------------|
| `domain`       | entities, repository contracts, use cases             | nothing (pure Dart) |
| `data`         | data sources, models, repository implementations      | domain             |
| `presentation` | Bloc/Cubit, pages, widgets                            | domain (use cases) |

### Reply engines

`AiEngine` (chat domain) has three implementations. `HybridAiEngine` is the one registered in DI:

```
HybridAiEngine ──► OnDeviceLlmEngine   (when a model is active)
               └─► RuleBasedAiEngine   (no model, or the LLM failed before any output)
```

To use a different runtime (for example llama.cpp), implement `AiEngine` and change one registration in
`core/di/modules/chat_module.dart`.

### How the code avoids repetition

- `guard()` is the only place that turns exceptions into `Failure`s, for every repository.
- `ChatRepositoryImpl._write()` wraps each write in `guard` and notifies watchers. The conversation list is a
  reactive stream, so nothing needs a manual refresh.
- `PatternIntentHandler` + `IntentCatalog`: the bot's skills are data. You add a skill without writing a class.
- `AppScaffold` / `BlocMessageListener`: one page shell and one SnackBar convention for every screen.
- `SettingsCubit._update()` is the single optimistic write path, with rollback, for every toggle.
- `NotifyUser` is the single notification gate: it checks the user's preference and whether the app is in the background.

## Tech stack

`flutter_bloc` · `get_it` · `go_router` · `shared_preferences` · `sqflite` · `flutter_local_notifications` ·
`flutter_gemma` (+ `_litertlm`, `_mediapipe`) · `flutter_markdown_plus` · `bloc_test` / `mocktail`

## Running

```bash
flutter pub get
flutter test
flutter run
```

**Android:** minSdk 24. `.litertlm` models (Qwen3) need an **arm64** device. `.task` models (Qwen 2.5, SmolLM) also
run on x86_64 emulators.

**iOS** (build on macOS): set the deployment target to **16.0**, add `platform :ios, '16.0'` and
`use_frameworks! :linkage => :static` to the Podfile, and add `UIFileSharingEnabled` to `Info.plist`. The full list
is in the flutter_gemma README under *Setup → iOS*.

**Windows dev machines:** `android/gradle.properties` sets `kotlin.incremental=false`. This works around a Kotlin
cache bug when the project and the pub cache are on different drives.
