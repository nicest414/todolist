<!-- Copilot instructions tailored for this Flutter TODO app -->
# Guidance for AI coding agents

This repository is a Flutter (Dart) TODO app using Riverpod for state management. The notes below are concise, actionable items an AI agent should know to be productive in this codebase.

- Project entry: `lib/main.dart` (uses `DevicePreview` in non-release builds and a `ProviderScope`).
- Main screens live under `lib/screens/` and are assembled in `lib/screens/home_screen.dart` using a PageView of five tabs: `AchievementsTab`, `ContinuousTodoTab`, `SugorokuTab`, `SingleTodoTab`, `MyPageTab`.
- State management: Riverpod. Main providers: `lib/providers/todo_provider.dart` (continuous & single todo providers, filters, search, layout flags), `lib/providers/theme_provider.dart`.
- Data models: `lib/models/todo_item.dart` defines `TodoItem`, `TodoChecklistItem`, `TodoView`, `TodoType`. Prefer using `copyWith` to modify items.
- UI patterns:
  - Item widget: `lib/widgets/todo_item_widget.dart` (dismissible, pin/toggle/delete flows, animated expansion, supports both card and list layouts via `useCardLayoutProvider`).
  - Add dialog: `lib/widgets/add_todo_dialog.dart` (parses tags as comma-separated, supports checklist, difficulty, notification/due date).

- Important conventions and patterns (do not change without care):
  - Two logical todo stores: `continuousTodoProvider` and `singleTodoProvider`. Keep their behavior parallel when adding/updating/removing items.
  - Search supports tag syntax: both `#[tag]` and `#tag`. See `filteredContinuousTodosProvider`/`filteredSingleTodosProvider` for parsing logic and sort order (pinned first, then by doneAt).
  - UI toggles and view state are stored in providers (e.g., `useCardLayoutProvider`, `todoViewProvider`, `searchQueryProvider`). Use providers for cross-widget state rather than local state where similar state already exists.
  - Use `StateNotifier` pattern for list operations (see `TodoNotifier` in `lib/providers/todo_provider.dart`). Follow its method names (`addTodo`, `removeTodo`, `toggleTodo`, `togglePin`, `updateTodo`, `reorderTodos`, `updateChecklistItem`).

- Build & developer workflows (from README and project files):
  - Install deps: `flutter pub get`
  - Codegen (Riverpod generator): `flutter packages pub run build_runner build` (or `watch` during development)
  - Analyze: `flutter analyze`
  - Run app: `flutter run` (DevicePreview enabled in debug)

- Files and locations to check for changes when modifying behavior:
  - Provider logic: `lib/providers/*.dart`
  - Data shapes: `lib/models/*.dart`
  - Screen wiring / tab order: `lib/screens/home_screen.dart`
  - Item UI and interactions: `lib/widgets/todo_item_widget.dart` and `lib/widgets/add_todo_dialog.dart`

- Minimal examples to follow when implementing features or fixes:
  - Add a todo (continuous): call `ref.read(continuousTodoProvider.notifier).addTodo(...)` with same args as dialog.
  - Toggle complete: call `ref.read(continuousTodoProvider.notifier).toggleTodo(id)` (or `singleTodoProvider` for single todos).
  - Preserve tag parsing behavior: when creating tags from text, split on `,`, trim, drop empty, deduplicate (see `AddTodoDialog`).

- Testing and QA tips:
  - Use `flutter test` for unit/widget tests. The repo currently includes `test/widget_test.dart`.
  - If you change generated providers or annotations, run `build_runner build` and `flutter clean` if build issues appear.

- When editing UI/logic, run a quick smoke test: `flutter run -d <device>` and exercise these flows: add todo with tags/checklist, toggle complete, pin/unpin via swipe, delete via swipe.

If anything here is unclear or you want more details (examples of provider usage, more files to reference, or a different verbosity), tell me which part to expand and I'll iterate.
