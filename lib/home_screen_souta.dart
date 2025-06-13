import 'package:flutter/material.dart';

class TodoItem {
  String title;
  DateTime? doneAt;
  bool isPinned;
  TodoItem(this.title, {this.doneAt, this.isPinned = false});
}

enum TodoView { undone, done }

class TodoListPage2 extends StatefulWidget {
  const TodoListPage2({super.key});

  @override
  State<TodoListPage2> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage2> {
  final List<TodoItem> _todosContinue = [];
  final List<TodoItem> _todosSingle = [];
  final TextEditingController _controller = TextEditingController();
  TodoView _view = TodoView.undone;
  int _selectedTabIndex = 3; // 4番目(todo単発タブ)を初期選択
  final PageController _pageController = PageController(initialPage: 3);

  String _profileName = 'ユーザー名';
  String _profileBio = '自己紹介を入力してください';

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todosContinue.add(TodoItem(text));
        _controller.clear();
      });
    }
  }

  void _toggleTodo(TodoItem item) {
    setState(() {
      if (item.doneAt == null) {
        item.doneAt = DateTime.now();
      } else {
        item.doneAt = null;
      }
    });
  }

  void _removeTodo(TodoItem item) {
    setState(() {
      _todosContinue.remove(item);
      _todosSingle.remove(item);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 未実行 or 実行済みリスト
    final List<TodoItem> displayList = _view == TodoView.undone
        ? _todosContinue.where((t) => t.doneAt == null).toList()
        : _todosContinue.where((t) => t.doneAt != null).toList()
            ..sort((a, b) {
              if (a.doneAt == null && b.doneAt == null) return 0;
              if (a.doneAt == null) return 1;
              if (b.doneAt == null) return -1;
              return a.doneAt!.compareTo(b.doneAt!);
            });

    // タブごとのタイトル
    final tabTitles = [
      '実績',
      'TODO継続',
      'すごろく',
      'TODO単発',
      'マイページ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tabTitles[_selectedTabIndex]),
        elevation: 0, // AppBarの下線を消す
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // タイトル下に線を引く
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.deepPurple.withOpacity(0.3),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // タスク追加・未/済ボタンは「TODO継続」または「TODO単発」タブのときだけ表示
                    if (_selectedTabIndex == 1 || _selectedTabIndex == 3) ...[
                      const SizedBox(height: 65), // ボタン分のスペース
                      const SizedBox(height: 35), // 未/済ボタンとタスクリストの間に余白
                    ],
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        children: [
                          // 各タブごとのウィジェット
                          _buildAchievementsTab(),
                          _buildTodoContinueTab(),
                          _buildSugorokuTab(),
                          _buildTodoSingleTab(),
                          _buildMyPageTab(),
                        ],
                      ),
                    ),
                  ],
                ),
                // 未/済ボタンをタイトル下・右寄せに配置（TODO継続・TODO単発タブのみ）
                if (_selectedTabIndex == 1 || _selectedTabIndex == 3)
                  Positioned(
                    right: 16,
                    top: kToolbarHeight,
                    child: Row(
                      children: [
                        // ここで「未」「済」の順番を逆にする
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _view == TodoView.undone ? Colors.deepPurple : Colors.white,
                            foregroundColor: _view == TodoView.undone ? Colors.white : Colors.deepPurple,
                            elevation: _view == TodoView.undone ? 4 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.deepPurple,
                                width: _view == TodoView.undone ? 2 : 1,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _view = TodoView.undone;
                            });
                          },
                          child: const Text('未'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _view == TodoView.done ? Colors.deepPurple : Colors.white,
                            foregroundColor: _view == TodoView.done ? Colors.white : Colors.deepPurple,
                            elevation: _view == TodoView.done ? 4 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.deepPurple,
                                width: _view == TodoView.done ? 2 : 1,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _view = TodoView.done;
                            });
                          },
                          child: const Text('済'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // タスク追加ボタンもTODO継続・TODO単発タブのみ
      floatingActionButton: (_view == TodoView.undone && (_selectedTabIndex == 1 || _selectedTabIndex == 3))
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('タスクを追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    final controller = TextEditingController();
                    int? selectedTab; // 0: 継続, 1: 単発, null: 未選択

                    final text = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('新しいタスクを追加'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
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
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<int>(
                                          title: const Text('継続'),
                                          value: 0,
                                          groupValue: selectedTab,
                                          onChanged: (val) => setState(() => selectedTab = val),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<int>(
                                          title: const Text('単発'),
                                          value: 1,
                                          groupValue: selectedTab,
                                          onChanged: (val) => setState(() => selectedTab = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('キャンセル'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final value = controller.text;
                                    if (value.trim().isNotEmpty) {
                                      Navigator.of(context).pop(value);
                                    }
                                  },
                                  child: const Text('追加'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    if (text != null && text.trim().isNotEmpty) {
                      setState(() {
                        // 追加先を決定
                        int tab = selectedTab ??
                            (_selectedTabIndex == 1 ? 0 : _selectedTabIndex == 3 ? 1 : 0);
                        if (tab == 0) {
                          _todosContinue.add(TodoItem(text.trim()));
                        } else {
                          _todosSingle.add(TodoItem(text.trim()));
                        }
                      });
                    }
                  },
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 5つのタブ
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. 実績タブ（四角アイコン）
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedTabIndex == 0 ? Colors.deepPurple : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.emoji_events,
                        color: _selectedTabIndex == 0 ? Colors.white : Colors.deepPurple),
                  ),
                  onPressed: () => _onTabTapped(0),
                  tooltip: '実績',
                ),
                // 2. todo継続タブ（四角アイコン・クリップボードアイコンに変更）
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedTabIndex == 1 ? Colors.deepPurple : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.assignment, // ←ここを修正
                        color: _selectedTabIndex == 1 ? Colors.white : Colors.deepPurple),
                  ),
                  onPressed: () => _onTabTapped(1),
                  tooltip: 'todo継続',
                ),
                // 3. すごろくタブ（丸アイコン）
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedTabIndex == 2 ? Colors.deepPurple : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.casino,
                        color: _selectedTabIndex == 2 ? Colors.white : Colors.deepPurple),
                  ),
                  onPressed: () => _onTabTapped(2),
                  tooltip: 'すごろく',
                ),
                // 4. todo単発タブ（四角アイコン）
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedTabIndex == 3 ? Colors.deepPurple : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.check_box,
                        color: _selectedTabIndex == 3 ? Colors.white : Colors.deepPurple),
                  ),
                  onPressed: () => _onTabTapped(3),
                  tooltip: 'todo単発',
                ),
                // 5. マイページ（四角アイコン）
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedTabIndex == 4 ? Colors.deepPurple : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.person,
                        color: _selectedTabIndex == 4 ? Colors.white : Colors.deepPurple),
                  ),
                  onPressed: () => _onTabTapped(4),
                  tooltip: 'マイページ',
                ),
              ],
            ),
          ),
          // FABのスペース確保
          if (_view == TodoView.undone)
            Positioned(
              bottom: 35,
              child: SizedBox(height: 56), // FABの高さ分スペース
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return Container(); // 実績タブのウィジェット
  }

  Widget _buildTodoContinueTab() {
    // 未/済の状態でリストを作成
    final List<TodoItem> displayList = _view == TodoView.undone
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
                orderedList.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);

                _todosContinue
                  ..remove(item)
                  ..insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
              });
            },
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final item = orderedList[index];
              return Padding(
                key: ValueKey(item),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                      key: ValueKey(item),
                      background: Container(
                        color: item.isPinned ? Colors.grey : Colors.amber,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          item.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
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
                            final controller = TextEditingController(text: item.title);
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
                                      onPressed: () => Navigator.of(context).pop(),
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
                            ? Row(
                                children: const [
                                  Icon(Icons.push_pin, color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text('固定中', style: TextStyle(color: Colors.amber, fontSize: 12)),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                ),  // ← Paddingのカッコ
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSugorokuTab() {
    return Container(); // すごろくタブのウィジェット
  }

  Widget _buildTodoSingleTab() {
    // 未/済の状態でリストを作成
    final List<TodoItem> displayList = _view == TodoView.undone
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    key: ValueKey(item),
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
                          final controller = TextEditingController(text: item.title);
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
                                    onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildMyPageTab() {
    final nameController = TextEditingController(text: _profileName);
    final emailController = TextEditingController(); // メールアドレス用
    final passwordController = TextEditingController(); // パスワード用
    final bioController = TextEditingController(text: _profileBio);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('マイページ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // 編集ダイアログを表示
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('プロフィール編集'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: '名前'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'メールアドレス'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordController,
                              decoration: const InputDecoration(labelText: 'パスワード'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: bioController,
                              decoration: const InputDecoration(labelText: '自己紹介'),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('キャンセル'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _profileName = nameController.text.trim().isEmpty
                                  ? 'ユーザー名'
                                  : nameController.text.trim();
                              _profileBio = bioController.text.trim().isEmpty
                                  ? '自己紹介を入力してください'
                                  : bioController.text.trim();
                              // emailController.text, passwordController.text も必要なら保存
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('プロフィールを保存しました')),
                            );
                          },
                          child: const Text('保存'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('プロフィール編集'),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text('現在のプロフィール', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(_profileName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_profileBio, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class Todo {
  String title;
  DateTime date;

  Todo(this.title, this.date);
}

class TodoManager {
  List<Todo> todos = [];

  // 今日のToDoを追加
  void addTodayTodo(String title) {
    todos.add(Todo(title, DateTime.now()));
  }

  // 日付順で取得
  List<Todo> getTodosSortedByDate() {
    todos.sort((a, b) => a.date.compareTo(b.date));
    return todos;
  }
}