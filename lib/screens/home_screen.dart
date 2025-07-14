import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_todo_dialog.dart';
import 'achievements_tab.dart';
import 'continuous_todo_tab.dart';
import 'single_todo_tab.dart';
import 'sugoroku_tab.dart';
import 'my_page_tab.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  // フィルター種別
  static const List<String> filterLabels = [
    'ノーマル',
    'タスク重い順',
    'タスク軽い順',
    'タイトル五十音順',
    '期限が近い順',
  ];
  int _selectedFilter = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(selectedTabIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    final view = ref.watch(todoViewProvider);
    final isSearching = ref.watch(isSearchingProvider);

    final tabTitles = [
      '実績',
      'TODO継続',
      'すごろく',
      'TODO単発',
      'マイページ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'タスクを検索',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : Text(tabTitles[selectedTabIndex]),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        actions: (selectedTabIndex == 1 || selectedTabIndex == 3)
            ? [
                IconButton(
                  icon: const Text('🔍', style: TextStyle(fontSize: 22)),
                  onPressed: () {
                    final currentSearching = ref.read(isSearchingProvider);
                    ref.read(isSearchingProvider.notifier).state =
                        !currentSearching;
                    if (currentSearching) {
                      ref.read(searchQueryProvider.notifier).state = '';
                    }
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
          // 進捗ゲージ（画面幅いっぱい）
          if (selectedTabIndex == 1 || selectedTabIndex == 3) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '進捗ゲージ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 仮のゲージ
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // タスク追加・未/済ボタンは「TODO継続」または「TODO単発」タブのときだけ表示
                    if (selectedTabIndex == 1 || selectedTabIndex == 3) ...[
                      const SizedBox(height: 65), // ボタン分のスペース
                      const SizedBox(height: 35), // 未/済ボタンとタスクリストの間に余白
                    ],
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          ref.read(selectedTabIndexProvider.notifier).state =
                              index;
                        },
                        children: const [
                          AchievementsTab(),
                          ContinuousTodoTab(),
                          SugorokuTab(),
                          SingleTodoTab(),
                          MyPageTab(),
                        ],
                      ),
                    ),
                  ],
                ),
                // 未/済ボタンとフィルターボタンをタイトル下・左右に配置（TODO継続・TODO単発タブのみ）
                if (selectedTabIndex == 1 || selectedTabIndex == 3)
                  Positioned(
                    left: 16,
                    top: 16,
                    child: PopupMenuButton<int>(
                      icon: const Icon(Icons.filter_alt, color: Colors.deepPurple, size: 28),
                      initialValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        // ここでフィルター処理を呼び出す（必要ならプロバイダーに反映）
                      },
                      itemBuilder: (context) => List.generate(filterLabels.length, (i) => PopupMenuItem(
                        value: i,
                        child: Text(filterLabels[i]),
                      )),
                      tooltip: 'タスクの並び替え',
                    ),
                  ),
                if (selectedTabIndex == 1 || selectedTabIndex == 3)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 未/済ボタンRow（既存のRowをそのまま）
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: view == TodoView.undone
                                    ? Colors.deepPurple
                                    : Colors.white,
                                foregroundColor: view == TodoView.undone
                                    ? Colors.white
                                    : Colors.deepPurple,
                                elevation: view == TodoView.undone ? 4 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.deepPurple,
                                    width: view == TodoView.undone ? 2 : 1,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                ref.read(todoViewProvider.notifier).state =
                                    TodoView.undone;
                              },
                              child: const Text('未'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: view == TodoView.done
                                    ? Colors.deepPurple
                                    : Colors.white,
                                foregroundColor: view == TodoView.done
                                    ? Colors.white
                                    : Colors.deepPurple,
                                elevation: view == TodoView.done ? 4 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.deepPurple,
                                    width: view == TodoView.done ? 2 : 1,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                ref.read(todoViewProvider.notifier).state =
                                    TodoView.done;
                              },
                              child: const Text('済'),
                            ),
                          ],
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
      floatingActionButton: (view == TodoView.undone &&
              (selectedTabIndex == 1 || selectedTabIndex == 3))
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddTodoDialog(
                        initialType: selectedTabIndex == 1
                            ? TodoType.continuous
                            : TodoType.single,
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar:
          _buildBottomNavigationBar(context, ref, selectedTabIndex),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, WidgetRef ref, int selectedTabIndex) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
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
          _buildTabButton(
            context,
            ref,
            0,
            Icons.emoji_events,
            '実績',
            selectedTabIndex,
            isSquare: true,
          ),
          _buildTabButton(
            context,
            ref,
            1,
            Icons.assignment,
            'todo継続',
            selectedTabIndex,
            isSquare: true,
          ),
          _buildTabButton(
            context,
            ref,
            2,
            Icons.casino,
            'すごろく',
            selectedTabIndex,
            isSquare: false,
          ),
          _buildTabButton(
            context,
            ref,
            3,
            Icons.check_box,
            'todo単発',
            selectedTabIndex,
            isSquare: true,
          ),
          _buildTabButton(
            context,
            ref,
            4,
            Icons.person,
            'マイページ',
            selectedTabIndex,
            isSquare: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String tooltip,
    int selectedTabIndex, {
    required bool isSquare,
  }) {
    final isSelected = selectedTabIndex == index;

    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isSquare ? BorderRadius.circular(8) : null,
          color: isSelected ? Colors.deepPurple : Colors.grey[300],
        ),
        padding: EdgeInsets.all(isSquare ? 8 : 10),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.deepPurple,
        ),
      ),
      onPressed: () {
        ref.read(selectedTabIndexProvider.notifier).state = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      tooltip: tooltip,
    );
  }
}