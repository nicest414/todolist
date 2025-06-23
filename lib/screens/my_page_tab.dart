import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_2/models/todo_item.dart';
import '../providers/todo_provider.dart';

class MyPageTab extends ConsumerStatefulWidget {
  const MyPageTab({super.key});

  @override
  ConsumerState<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends ConsumerState<MyPageTab> {
  String _profileName = '';
  String _profileBio = '';
  String? _loggedInEmail; // 追加：ログイン中のメールアドレス

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: _profileName);
    final bioController = TextEditingController(text: _profileBio);

    // 継続タスクと単発タスクのリストをProviderから取得
    final List<TodoItem> todosContinue = ref.watch(continuousTodoProvider);
    final List<TodoItem> todosSingle = ref.watch(singleTodoProvider);
    final int loginDays = 1; // ログイン日数は別途実装
    final int totalTasks = todosContinue.length + todosSingle.length;
    final int completedTasks =
        todosContinue.where((t) => t.isCompleted).length +
        todosSingle.where((t) => t.isCompleted).length;
    final List<String> todayTodos = []; // 今日のタスクは別途実装

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ↓ここを追加
            if (_loggedInEmail != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${_loggedInEmail!} でログインしています',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // 1. ログインボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final emailController = TextEditingController();
                  final passwordController = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('ログイン'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('キャンセル'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _loggedInEmail = emailController.text.trim();
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('ログイン'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('ログイン'),
              ),
            ),
            const SizedBox(height: 24),
            // 2. プロフィール編集
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
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
                                decoration:
                                    const InputDecoration(labelText: '名前'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: bioController,
                                decoration:
                                    const InputDecoration(labelText: '自己紹介'),
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
                                _profileName =
                                    nameController.text.trim().isEmpty
                                        ? 'ユーザー名'
                                        : nameController.text.trim();
                                _profileBio = bioController.text.trim().isEmpty
                                    ? '自己紹介を入力してください'
                                    : bioController.text.trim();
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
            const SizedBox(height: 24),
            // 3. データ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('データ'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ログイン日数: $loginDays 日'),
                            Text('登録タスク: $totalTasks 件'),
                            Text('完了のタスク: $completedTasks 件'),
                            const SizedBox(height: 16),
                            const Text('今日やったtodo',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ...todayTodos.isEmpty
                                ? [const Text('まだありません')]
                                : todayTodos
                                    .map((todo) => Text('- $todo'))
                                    .toList(),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('閉じる'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('データ'),
              ),
            ),
            const SizedBox(height: 24),
            // 4. 各種詳細設定
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('各種詳細設定'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // 通知・リマインダー設定画面へ遷移など
                                },
                                child: const Text('通知・リマインダー'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // 外観・デザイン設定画面へ遷移など
                                },
                                child: const Text('外観・デザイン'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // サウンド・バイブ設定画面へ遷移など
                                },
                                child: const Text('サウンド・バイブ'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('アプリ情報・ヘルプ'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.menu_book),
                                              title: const Text('使い方ガイド'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('使い方ガイド'),
                                                    content: const Text('TODOリストの使い方ガイドをここに記載します。'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('閉じる'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.question_answer),
                                              title: const Text('よくあるQ＆A'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('よくあるQ＆A'),
                                                    content: const Text('よくある質問と回答をここに記載します。'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('閉じる'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.contact_mail),
                                              title: const Text('お問い合わせフォーム'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('お問い合わせフォーム'),
                                                    content: const Text('お問い合わせフォームをここに記載します。'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('閉じる'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.casino),
                                              title: const Text('todoすごろく ver.1.0'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('todoすごろく ver.1.0'),
                                                    content: const Text('todoすごろく ver.1.0の説明やリンクをここに記載します。'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('閉じる'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('閉じる'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('アプリ情報・ヘルプ'),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('閉じる'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('各種詳細設定'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
