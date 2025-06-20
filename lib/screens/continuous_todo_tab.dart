import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_widget.dart';

class ContinuousTodoTab extends ConsumerWidget {
  const ContinuousTodoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredContinuousTodosProvider);
    final view = ref.watch(todoViewProvider);

    return Column(
      children: [
        Expanded(
          child: todos.isEmpty
              ? Center(
                  child: Text(
                    view == TodoView.undone
                        ? '継続TODOがありません\n右下のボタンから追加してください'
                        : '完了した継続TODOがありません',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: todos.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(continuousTodoProvider.notifier)
                        .reorderTodos(oldIndex, newIndex);
                  },
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(todo.id),
                      index: index,
                      child: TodoItemWidget(
                        todo: todo,
                        isContinuous: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
