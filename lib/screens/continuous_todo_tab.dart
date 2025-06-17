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

class ContinuousTodoTab extends ConsumerStatefulWidget {
  const ContinuousTodoTab({super.key});

  @override
  ConsumerState<ContinuousTodoTab> createState() => _ContinuousTodoTabState();
}

class _ContinuousTodoTabState extends ConsumerState<ContinuousTodoTab> {
  final List<LocalTodoItem> _todosContinue = [];
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
      _todosContinue.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 未/済の状態でリストを作成
    final List<LocalTodoItem> displayList = _view == TodoView.undone
        ? _todosContinue.where((t) => t.doneAt == null).toList()
        : _todosContinue.where((t) => t.doneAt != null).toList()
      ..sort((a, b) {
        if (a.doneAt == null && b.doneAt == null) return 0;
        if (a.doneAt == null) return 1;
        if (b.doneAt == null) return -1;
        return a.doneAt!.compareTo(b.doneAt!);
      });

    // ピン付きタスクを先頭に表示
    final pinned = displayList.where((t) => t.isPinned).toList();
    final unpinned = displayList.where((t) => !t.isPinned).toList();
    final orderedList = [...pinned, ...unpinned];

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: orderedList.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final pinnedCount = pinned.length;
                final isOldPinned = oldIndex < pinnedCount;
                final isNewPinned = newIndex <= pinnedCount;

                // ピン付き→ピンなし、またはピンなし→ピン付きの移動は禁止
                // ただし、ピンなしタスクをピン付きの直後(newIndex == pinnedCount)に移動するのは許可
                if (isOldPinned != isNewPinned && newIndex != pinnedCount) {
                  return;
                }

                final item = orderedList.removeAt(oldIndex);
                orderedList.insert(
                    newIndex > oldIndex ? newIndex - 1 : newIndex, item);

                _todosContinue
                  ..remove(item)
                  ..insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
              });
            },
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final item = orderedList[index];
              return Padding(
                key: ValueKey(item.title),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.isPinned
                            ? Colors.amber
                            : Colors.deepPurple.withOpacity(0.3),
                        width: 1.5,
                      ),
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
                        color: item.isPinned ? Colors.grey : Colors.amber,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          item.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          setState(() {
                            item.isPinned = !item.isPinned;
                          });
                          return false; // Dismissibleを消さない
                        } else if (direction == DismissDirection.endToStart) {
                          return true; // Dismissibleを消す
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          // 右から左：削除
                          _removeTodo(item);
                        }
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTodo(item),
                        ),
                        subtitle: item.isPinned
                            ? const Row(
                                children: [
                                  Icon(Icons.push_pin,
                                      color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text('固定中',
                                      style: TextStyle(
                                          color: Colors.amber, fontSize: 12)),
                                ],
                              )
                            : null,
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
