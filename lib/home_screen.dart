import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TodoChecklistItem {
  String title;
  bool isChecked;
  TodoChecklistItem(this.title, {this.isChecked = false});
}

class TodoItem {
  String title;
  String memo;
  DateTime? doneAt;
  bool isPinned;
  List<TodoChecklistItem> checklist;
  DateTime? notificationTime; // ←追加
  DateTime? dueDate; // 追加

  TodoItem(
    this.title, {
    this.memo = '',
    this.doneAt,
    this.isPinned = false,
    List<TodoChecklistItem>? checklist,
    this.notificationTime,
    this.dueDate, // ←追加
  }) : checklist = checklist ?? [];
}

enum TodoView { undone, done }

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<TodoItem> _todosContinue = [];
  final List<TodoItem> _todosSingle = [];
  final TextEditingController _controller = TextEditingController();
  TodoView _view = TodoView.undone;
  int _selectedTabIndex = 1; // 2番目(todo継続タブ)を初期選択
  final PageController _pageController = PageController(initialPage: 1);

  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'タスクを検索',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(tabTitles[_selectedTabIndex]),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        actions: (_selectedTabIndex == 1 || _selectedTabIndex == 3)
            ? [
                IconButton(
                  icon: const Text('🔍', style: TextStyle(fontSize: 22)),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchQuery = '';
                        _searchController.clear();
                      }
                    });
                  },
                ),
              ]
            : null,
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
                    final memoController = TextEditingController();
                    int? selectedTab;
                    List<TodoChecklistItem> tempChecklist = [];
                    List<TextEditingController> checklistControllers = [];
                    final checklistScrollController = ScrollController();
                    DateTime? notificationTime;
                    DateTime? dueDate; // ← ここを追加

                    final text = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            void scrollToEnd() {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                checklistScrollController.animateTo(
                                  checklistScrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                            }

                            return AlertDialog(
                              title: const Text('新しいタスクを追加'),
                              content: SingleChildScrollView(
                                controller: checklistScrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        labelText: 'タスク内容',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: memoController,
                                      decoration: const InputDecoration(
                                        labelText: '詳細メモ（任意）',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Text('チェックリスト', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              tempChecklist.add(TodoChecklistItem(''));
                                              checklistControllers.add(TextEditingController());
                                            });
                                            scrollToEnd();
                                          },
                                        ),
                                      ],
                                    ),
                                    ...List.generate(tempChecklist.length, (i) {
                                      return Row(
                                        children: [
                                          Checkbox(
                                            value: tempChecklist[i].isChecked,
                                            onChanged: (checked) {
                                              setState(() {
                                                tempChecklist[i].isChecked = checked ?? false;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: checklistControllers[i],
                                              decoration: const InputDecoration(
                                                hintText: 'チェックリスト項目',
                                              ),
                                              onChanged: (val) {
                                                tempChecklist[i].title = val;
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                tempChecklist.removeAt(i);
                                                checklistControllers.removeAt(i);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }),
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
                                    // ↓ここに通知機能UIを追加
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.notifications, color: Colors.deepPurple),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            notificationTime == null
                                                ? '通知時刻を設定しない'
                                                : '通知: ${notificationTime!.hour.toString().padLeft(2, '0')}:${notificationTime!.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final now = DateTime.now();
                                            DateTime tempTime = notificationTime ?? DateTime(now.year, now.month, now.day, now.hour, now.minute);

                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                                  content: SizedBox(
                                                    height: 200,
                                                    width: 300,
                                                    child: CupertinoDatePicker(
                                                      mode: CupertinoDatePickerMode.time,
                                                      initialDateTime: tempTime,
                                                      use24hFormat: true,
                                                      onDateTimeChanged: (DateTime newTime) {
                                                        tempTime = newTime;
                                                      },
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
                                                          notificationTime = tempTime;
                                                        });
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('決定'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Text('時刻を設定'),
                                        ),
                                        if (notificationTime != null)
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            onPressed: () => setState(() => notificationTime = null),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.event, color: Colors.deepPurple),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dueDate == null
                                                ? '期限日を設定しない'
                                                : '期限: ${dueDate!.year}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.day.toString().padLeft(2, '0')}',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final now = DateTime.now();
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: dueDate ?? now,
                                              firstDate: now,
                                              lastDate: DateTime(now.year + 5),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                dueDate = picked;
                                              });
                                            }
                                          },
                                          child: const Text('期限を設定'),
                                        ),
                                        if (dueDate != null)
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            onPressed: () => setState(() => dueDate = null),
                                          ),
                                      ],
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
                                    if (controller.text.trim().isNotEmpty) {
                                      Navigator.of(context).pop('OK');
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
                    if (text == 'OK' && controller.text.trim().isNotEmpty) {
                      setState(() {
                        int tab = selectedTab ?? (_selectedTabIndex == 1 ? 0 : _selectedTabIndex == 3 ? 1 : 0);
                        final title = controller.text.trim();
                        final memo = memoController.text.trim();
                        final checklist = tempChecklist.where((c) => c.title.trim().isNotEmpty).toList();
                        if (tab == 0) {
                          _todosContinue.add(TodoItem(
                            title,
                            memo: memo,
                            checklist: checklist,
                            notificationTime: notificationTime, // ←追加
                          ));
                        } else {
                          _todosSingle.add(TodoItem(
                            title,
                            memo: memo,
                            checklist: checklist,
                          ));
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
    final List<TodoItem> displayList = _view == TodoView.undone
        ? _todosContinue.where((t) => t.doneAt == null).toList()
        : _todosContinue.where((t) => t.doneAt != null).toList()
            ..sort((a, b) {
              if (a.doneAt == null && b.doneAt == null) return 0;
              if (a.doneAt == null) return 1;
              if (b.doneAt == null) return -1;
              return a.doneAt!.compareTo(b.doneAt!);
            });

    // 検索クエリがあればフィルタ
    final filteredList = _searchQuery.isEmpty
        ? displayList
        : displayList.where((t) => t.title.contains(_searchQuery)).toList();

    // ピン付きタスクを先頭に表示
    final pinned = filteredList.where((t) => t.isPinned).toList();
    final unpinned = filteredList.where((t) => !t.isPinned).toList();
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
                            final memoController = TextEditingController(text: item.memo);
                            List<TodoChecklistItem> tempChecklist = item.checklist.map((c) => TodoChecklistItem(c.title, isChecked: c.isChecked)).toList();
                            final checklistControllers = tempChecklist.map((c) => TextEditingController(text: c.title)).toList();
                            final checklistScrollController = ScrollController(); // 追加

                            await showDialog<void>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    void scrollToEnd() {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        checklistScrollController.animateTo(
                                          checklistScrollController.position.maxScrollExtent,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      });
                                    }

                                    return AlertDialog(
                                      title: const Text('タスクを編集'),
                                      content: SingleChildScrollView(
                                        controller: checklistScrollController, // 追加
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: controller,
                                              autofocus: true,
                                              decoration: const InputDecoration(labelText: 'タスク内容'),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: memoController,
                                              decoration: const InputDecoration(labelText: '詳細メモ'),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Text('チェックリスト', style: TextStyle(fontWeight: FontWeight.bold)),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      tempChecklist.add(TodoChecklistItem(''));
                                                      checklistControllers.add(TextEditingController());
                                                    });
                                                    scrollToEnd(); // 追加
                                                  },
                                                ),
                                              ],
                                            ),
                                            ...List.generate(tempChecklist.length, (i) {
                                              return Row(
                                                children: [
                                                  Checkbox(
                                                    value: tempChecklist[i].isChecked,
                                                    onChanged: (checked) {
                                                      setState(() {
                                                        tempChecklist[i].isChecked = checked ?? false;
                                                      });
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: checklistControllers[i],
                                                      decoration: const InputDecoration(
                                                        hintText: 'チェックリスト項目',
                                                      ),
                                                      onChanged: (val) {
                                                        tempChecklist[i].title = val;
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete),
                                                    onPressed: () {
                                                      setState(() {
                                                        tempChecklist.removeAt(i);
                                                        checklistControllers.removeAt(i);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.notifications, color: Colors.deepPurple),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item.notificationTime == null
                                                        ? '通知時刻を設定しない'
                                                        : '通知: ${item.notificationTime!.hour.toString().padLeft(2, '0')}:${item.notificationTime!.minute.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    final now = DateTime.now();
                                                    DateTime tempTime = item.notificationTime ?? DateTime(now.year, now.month, now.day, now.hour, now.minute);

                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                                          content: SizedBox(
                                                            height: 200,
                                                            width: 300,
                                                            child: CupertinoDatePicker(
                                                              mode: CupertinoDatePickerMode.time,
                                                              initialDateTime: tempTime,
                                                              use24hFormat: true,
                                                              onDateTimeChanged: (DateTime newTime) {
                                                                tempTime = newTime;
                                                              },
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
                                                                  item.notificationTime = tempTime;
                                                                });
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Text('決定'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Text('時刻を設定'),
                                                ),
                                                if (item.notificationTime != null)
                                                  IconButton(
                                                    icon: const Icon(Icons.close, size: 18),
                                                    onPressed: () => setState(() => item.notificationTime = null),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.event, color: Colors.deepPurple),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item.dueDate == null
                                                        ? '期限日を設定しない'
                                                        : '期限: ${item.dueDate!.year}/${item.dueDate!.month.toString().padLeft(2, '0')}/${item.dueDate!.day.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    final now = DateTime.now();
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: item.dueDate ?? now,
                                                      firstDate: now,
                                                      lastDate: DateTime(now.year + 5),
                                                    );
                                                    if (picked != null) {
                                                      setState(() {
                                                        item.dueDate = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text('期限を設定'),
                                                ),
                                                if (item.dueDate != null)
                                                  IconButton(
                                                    icon: const Icon(Icons.close, size: 18),
                                                    onPressed: () => setState(() => item.dueDate = null),
                                                  ),
                                              ],
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
                                              item.title = controller.text.trim();
                                              item.memo = memoController.text.trim();
                                              item.checklist = tempChecklist.where((c) => c.title.trim().isNotEmpty).toList();
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('保存'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text(
                            item.title,
                            style: (_view == TodoView.done)
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${item.dueDate!.month.toString().padLeft(2, '0')}/${item.dueDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeTodo(item),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.memo.isNotEmpty)
                              Text(
                                item.memo,
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            if (item.notificationTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.notifications, size: 16, color: Colors.deepPurple),
                                    const SizedBox(width: 4),
                                    Text(
                                      '通知: ${item.notificationTime!.hour.toString().padLeft(2, '0')}:${item.notificationTime!.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.deepPurple, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            if (item.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event, size: 16, color: Colors.deepPurple),
                                    const SizedBox(width: 4),
                                    Text(
                                      '期限: ${item.dueDate!.year}/${item.dueDate!.month.toString().padLeft(2, '0')}/${item.dueDate!.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.deepPurple, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            if (item.checklist.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  children: item.checklist.map((checkItem) {
                                    return Row(
                                      children: [
                                        Checkbox(
                                          value: checkItem.isChecked,
                                          onChanged: (checked) {
                                            setState(() {
                                              checkItem.isChecked = checked ?? false;
                                            });
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Expanded(
                                          child: Text(
                                            checkItem.title,
                                            style: TextStyle(
                                              decoration: checkItem.isChecked ? TextDecoration.lineThrough : null,
                                              color: checkItem.isChecked ? Colors.grey : Colors.black87,
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
    final List<TodoItem> displayList = _view == TodoView.undone
        ? _todosSingle.where((t) => t.doneAt == null).toList()
        : _todosSingle.where((t) => t.doneAt != null).toList()
            ..sort((a, b) {
              if (a.doneAt == null && b.doneAt == null) return 0;
              if (a.doneAt == null) return 1;
              if (b.doneAt == null) return -1;
              return a.doneAt!.compareTo(b.doneAt!);
            });

    // 検索クエリがあればフィルタ
    final filteredList = _searchQuery.isEmpty
        ? displayList
        : displayList.where((t) => t.title.contains(_searchQuery)).toList();

    // ピン付きタスクを先頭に表示
    final pinned = filteredList.where((t) => t.isPinned).toList();
    final unpinned = filteredList.where((t) => !t.isPinned).toList();
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

                // ピン付き⇔ピンなしの間の移動は禁止（ただし直後はOK）
                if (isOldPinned != isNewPinned && newIndex != pinnedCount) {
                  return;
                }

                final item = orderedList.removeAt(oldIndex);
                orderedList.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);

                _todosSingle
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${item.dueDate!.month.toString().padLeft(2, '0')}/${item.dueDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeTodo(item),
                            ),
                          ],
                        ),
                        subtitle: item.memo.isNotEmpty
                            ? Text(
                                item.memo,
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
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

  Widget _buildMyPageTab() {
    return Container(); // マイページタブのウィジェット
  }
}