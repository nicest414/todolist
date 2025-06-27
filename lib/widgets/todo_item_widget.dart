import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';

class TodoItemWidget extends ConsumerWidget {
  final TodoItem todo;
  final bool isContinuous;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.isContinuous,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        color: isContinuous
            ? (todo.isPinned ? Colors.grey : Colors.amber)
            : Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: isContinuous
            ? Icon(
                todo.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: Colors.white,
              )
            : null,
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: isContinuous
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && isContinuous) {
          // 左から右：ピン留め切り替え（継続TODOのみ）
          ref.read(continuousTodoProvider.notifier).togglePin(todo.id);
          return false; // Dismissibleを消さない
        } else if (direction == DismissDirection.endToStart) {
          // 右から左：削除確認
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('削除確認'),
                  content: Text('「${todo.title}」を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('削除',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ) ??
              false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // 削除処理
          if (isContinuous) {
            ref.read(continuousTodoProvider.notifier).removeTodo(todo.id);
          } else {
            ref.read(singleTodoProvider.notifier).removeTodo(todo.id);
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        elevation: 2,
        child: Column(
          children: [
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ピン留めアイコン
                  if (todo.isPinned)
                    const Icon(
                      Icons.push_pin,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  // チェックボックス
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      if (isContinuous) {
                        ref
                            .read(continuousTodoProvider.notifier)
                            .toggleTodo(todo.id);
                      } else {
                        ref
                            .read(singleTodoProvider.notifier)
                            .toggleTodo(todo.id);
                      }
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration:
                      todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                  fontWeight:
                      todo.isPinned ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.memo.isNotEmpty)
                    Text(
                      todo.memo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  if (todo.dueDate != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '期限: ${todo.dueDate!.year}/${todo.dueDate!.month.toString().padLeft(2, '0')}/${todo.dueDate!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  if (todo.notificationTime != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '通知: ${todo.notificationTime!.hour.toString().padLeft(2, '0')}:${todo.notificationTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  // ピン留めされている場合の表示
                  if (todo.isPinned)
                    const Row(
                      children: [
                        Icon(Icons.push_pin, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '固定中',
                          style: TextStyle(color: Colors.amber, fontSize: 12),
                        ),
                      ],
                    ),
                  // チェックリストをタイトルの下の階層に移動 (todocontinueeeブランチの変更を適用)
                  if (todo.checklist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: todo.checklist.asMap().entries.map((entry) {
                          final index = entry.key;
                          final checklistItem = entry.value;
                          return Row(
                            children: [
                              Checkbox(
                                value: checklistItem.isChecked,
                                onChanged: (checked) {
                                  if (isContinuous) {
                                    ref
                                        .read(continuousTodoProvider.notifier)
                                        .updateChecklistItem(
                                          todo.id,
                                          index,
                                          isChecked: checked ?? false,
                                        );
                                  } else {
                                    ref
                                        .read(singleTodoProvider.notifier)
                                        .updateChecklistItem(
                                          todo.id,
                                          index,
                                          isChecked: checked ?? false,
                                        );
                                  }
                                },
                                activeColor: Colors.deepPurple,
                              ),
                              Expanded(
                                child: Text(
                                  checklistItem.title,
                                  style: TextStyle(
                                    decoration: checklistItem.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: checklistItem.isChecked
                                        ? Colors.grey
                                        : null,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'pin':
                      if (isContinuous) {
                        ref
                            .read(continuousTodoProvider.notifier)
                            .togglePin(todo.id);
                      } else {
                        ref
                            .read(singleTodoProvider.notifier)
                            .togglePin(todo.id);
                      }
                      break;
                    case 'delete':
                      if (isContinuous) {
                        ref
                            .read(continuousTodoProvider.notifier)
                            .removeTodo(todo.id);
                      } else {
                        ref
                            .read(singleTodoProvider.notifier)
                            .removeTodo(todo.id);
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          todo.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(todo.isPinned ? 'ピン解除' : 'ピン留め'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('削除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}