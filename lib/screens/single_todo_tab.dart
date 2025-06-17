import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';

// 簡単なTodoItemクラス（home_screen_souta.dartと同じ構造）
class LocalTodoItem {
  String title;
  DateTime? doneAt;
  bool isPinned;
  bool notificationEnabled;

  LocalTodoItem(this.title,
      {this.doneAt, this.isPinned = false, this.notificationEnabled = false});
}

class SingleTodoTab extends ConsumerStatefulWidget {
  const SingleTodoTab({super.key});

  @override
  ConsumerState<SingleTodoTab> createState() => _SingleTodoTabState();
}

class _SingleTodoTabState extends ConsumerState<SingleTodoTab> {
  final List<LocalTodoItem> _todosSingle = [];
  TodoView _view = TodoView.undone;

  void _toggleTodo(LocalTodoItem item) {
    setState(() {
      if (item.doneAt == null) {
        item.doneAt = DateTime.now();
      } else {
        item.doneAt = null;
      }
    });
  }

  void _removeTodo(LocalTodoItem item) {
    setState(() {
      _todosSingle.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 未/済の状態でリストを作成
    final List<LocalTodoItem> displayList = _view == TodoView.undone
        ? _todosSingle.where((t) => t.doneAt == null).toList()
        : _todosSingle.where((t) => t.doneAt != null).toList()
      ..sort((a, b) {
        if (a.doneAt == null && b.doneAt == null) return 0;
        if (a.doneAt == null) return 1;
        if (b.doneAt == null) return -1;
        return a.doneAt!.compareTo(b.doneAt!);
      });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Dismissible(
                    key: ValueKey(item.title),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return true; // Dismissibleを消す
                    },
                    onDismissed: (direction) {
                      // 右から左：削除
                      _removeTodo(item);
                    },
                    child: ListTile(
                      leading: Checkbox(
                        value: item.doneAt != null,
                        onChanged: (checked) {
                          _toggleTodo(item);
                        },
                      ),
                      title: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final controller =
                              TextEditingController(text: item.title);
                          final edited = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('タスクを編集'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    labelText: 'タスク内容',
                                  ),
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      Navigator.of(context).pop(value);
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('キャンセル'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final value = controller.text;
                                      if (value.trim().isNotEmpty) {
                                        Navigator.of(context).pop(value);
                                      }
                                    },
                                    child: const Text('保存'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (edited != null && edited.trim().isNotEmpty) {
                            setState(() {
                              item.title = edited.trim();
                            });
                          }
                        },
                        child: Text(
                          item.title,
                          style: (_view == TodoView.done)
                              ? const TextStyle(
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
