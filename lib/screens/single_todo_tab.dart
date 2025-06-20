import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_widget.dart';

class SingleTodoTab extends ConsumerWidget {
  const SingleTodoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredSingleTodosProvider);
    final view = ref.watch(todoViewProvider);

    return Column(
      children: [
        Expanded(
          child: todos.isEmpty
              ? Center(
                  child: Text(
                    view == TodoView.undone
                        ? '単発TODOがありません\n右下のボタンから追加してください'
                        : '完了した単発TODOがありません',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoItemWidget(
                      todo: todo,
                      isContinuous: false,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
