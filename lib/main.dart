import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: const MyHomePage(title: 'todo(単発)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // タスクをMapで管理（titleとisDone）
  final List<Map<String, dynamic>> _todos = [];
  final TextEditingController _controller = TextEditingController();

  // タスク追加
  void _addTodo(String title) {
    setState(() {
      _todos.add({'title': title, 'isDone': false});
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      _todos[index]['isDone'] = !_todos[index]['isDone'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // チェック済みタスク数を計算
    int doneCount = _todos.where((todo) => todo['isDone'] == true).length;
    int totalCount = _todos.length;
    int notDoneCount = totalCount - doneCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // タイトルに未/済を表示
        title: Text('todo(単発)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // プログレスバーを追加
            LinearProgressIndicator(
              value: totalCount == 0 ? 0 : doneCount / totalCount,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final newTask = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTodoPage()),
                  );
                  if (newTask != null && newTask.isNotEmpty) {
                    _addTodo(newTask);
                  }
                },
                child: const Text('+todo追加'),
              ),
            ),
            const SizedBox(height: 16),
            // ここから追加
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '未',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // 済タスクだけを抽出してページ遷移
                    final doneTodos = _todos.where((todo) => todo['isDone'] == true).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoneTodoPage(doneTodos: doneTodos),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '済',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ここまで追加
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      value: _todos[index]['isDone'],
                      onChanged: (bool? value) {
                        _toggleDone(index);
                      },
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _todos[index]['isDone'] ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _todos[index]['isDone'] ? '済' : '未',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _todos[index]['title'],
                            style: TextStyle(
                              decoration: _todos[index]['isDone']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTodo(index),
                      tooltip: '消去',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 新しい画面のウィジェットを追加
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しいタスク')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'タスクを入力'),
              autofocus: true,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.pop(context, _controller.text);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}

// 済タスク一覧ページ
class DoneTodoPage extends StatelessWidget {
  final List<Map<String, dynamic>> doneTodos;
  const DoneTodoPage({super.key, required this.doneTodos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('済タスク一覧')),
      body: ListView.builder(
        itemCount: doneTodos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              doneTodos[index]['title'],
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
        },
      ),
    );
  }
}
