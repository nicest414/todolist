import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';

class TodoNotifier extends StateNotifier<List<TodoItem>> {
  TodoNotifier() : super([]);

  void addTodo(
    String title, {
    String memo = '',
    List<TodoChecklistItem>? checklist,
    DateTime? notificationTime,
    DateTime? dueDate,
    TodoType type = TodoType.continuous,
  }) {
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      memo: memo,
      checklist: checklist ?? [],
      notificationTime: notificationTime,
      dueDate: dueDate,
    );
    state = [...state, newTodo];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          doneAt: todo.doneAt == null ? DateTime.now() : null,
        );
      }
      return todo;
    }).toList();
  }

  void togglePin(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isPinned: !todo.isPinned);
      }
      return todo;
    }).toList();
  }

  void updateTodo(
    String id, {
    String? title,
    String? memo,
    List<TodoChecklistItem>? checklist,
    DateTime? notificationTime,
    DateTime? dueDate,
    bool? notificationEnabled,
  }) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          title: title,
          memo: memo,
          checklist: checklist,
          notificationTime: notificationTime,
          dueDate: dueDate,
          notificationEnabled: notificationEnabled,
        );
      }
      return todo;
    }).toList();
  }

  void reorderTodos(int oldIndex, int newIndex) {
    final todos = [...state];
    final item = todos.removeAt(oldIndex);
    todos.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = todos;
  }

  void updateChecklistItem(
    String todoId,
    int checklistIndex, {
    String? title,
    bool? isChecked,
  }) {
    state = state.map((todo) {
      if (todo.id == todoId && checklistIndex < todo.checklist.length) {
        final updatedChecklist = [...todo.checklist];
        updatedChecklist[checklistIndex] =
            updatedChecklist[checklistIndex].copyWith(
          title: title,
          isChecked: isChecked,
        );
        return todo.copyWith(checklist: updatedChecklist);
      }
      return todo;
    }).toList();
  }
}

// 継続TODOプロバイダー
final continuousTodoProvider =
    StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier();
});

// 単発TODOプロバイダー
final singleTodoProvider =
    StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier();
});

// 現在のビュー（未完了/完了）プロバイダー
final todoViewProvider = StateProvider<TodoView>((ref) => TodoView.undone);

// 検索クエリプロバイダー
final searchQueryProvider = StateProvider<String>((ref) => '');

// 検索状態プロバイダー
final isSearchingProvider = StateProvider<bool>((ref) => false);

// 選択されたタブインデックスプロバイダー
final selectedTabIndexProvider = StateProvider<int>((ref) => 1);

// フィルタリングされた継続TODOプロバイダー
final filteredContinuousTodosProvider = Provider<List<TodoItem>>((ref) {
  final todos = ref.watch(continuousTodoProvider);
  final view = ref.watch(todoViewProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filteredTodos = view == TodoView.undone
      ? todos.where((todo) => !todo.isCompleted).toList()
      : todos.where((todo) => todo.isCompleted).toList();

  if (searchQuery.isNotEmpty) {
    filteredTodos = filteredTodos
        .where((todo) =>
            todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // ソート処理
  filteredTodos.sort((a, b) {
    // ピン留めされたアイテムを先頭に
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;

    // 完了日時でソート
    if (a.doneAt == null && b.doneAt == null) return 0;
    if (a.doneAt == null) return 1;
    if (b.doneAt == null) return -1;
    return a.doneAt!.compareTo(b.doneAt!);
  });

  return filteredTodos;
});

// フィルタリングされた単発TODOプロバイダー
final filteredSingleTodosProvider = Provider<List<TodoItem>>((ref) {
  final todos = ref.watch(singleTodoProvider);
  final view = ref.watch(todoViewProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filteredTodos = view == TodoView.undone
      ? todos.where((todo) => !todo.isCompleted).toList()
      : todos.where((todo) => todo.isCompleted).toList();

  if (searchQuery.isNotEmpty) {
    filteredTodos = filteredTodos
        .where((todo) =>
            todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // ソート処理
  filteredTodos.sort((a, b) {
    // ピン留めされたアイテムを先頭に
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;

    // 完了日時でソート
    if (a.doneAt == null && b.doneAt == null) return 0;
    if (a.doneAt == null) return 1;
    if (b.doneAt == null) return -1;
    return a.doneAt!.compareTo(b.doneAt!);
  });

  return filteredTodos;
});
