import 'package:flutter/material.dart';

class DataPage extends StatelessWidget {
  final int loginDays;
  final int totalTasks;
  final int completedTasks;
  final List<String> todayTodos;

  const DataPage({
    super.key,
    required this.loginDays,
    required this.totalTasks,
    required this.completedTasks,
    required this.todayTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('データ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ログイン日数: $loginDays 日', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('登録タスク: $totalTasks 件', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('完了のタスク: $completedTasks 件',
                style: const TextStyle(fontSize: 18)),
            const Divider(height: 32),
            const Text('今日やったtodo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...todayTodos.isEmpty
                ? [const Text('まだありません')]
                : todayTodos.map((todo) => Text('- $todo')).toList(),
          ],
        ),
      ),
    );
  }
}
