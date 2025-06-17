import 'package:flutter/material.dart';

class MyPageTab extends StatefulWidget {
  const MyPageTab({super.key});

  @override
  State<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends State<MyPageTab> {
  String _profileName = '';
  String _profileBio = '';

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: _profileName);
    final bioController = TextEditingController(text: _profileBio);

    final int loginDays = 0;
    final int totalTasks = 0; // 実際のタスク数は別途取得
    final int completedTasks = 0; // 実際の完了タスク数は別途取得
    final List<String> todayTodos = []; // 今日のタスクは別途取得

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ログインボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // ボタンの背景色を緑に
                  foregroundColor: Colors.white, // 文字色を白に
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
                              decoration:
                                  const InputDecoration(labelText: 'メールアドレス'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordController,
                              decoration:
                                  const InputDecoration(labelText: 'パスワード'),
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
                              // ログイン処理をここに実装
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
                                  // アプリ情報・ヘルプ画面へ遷移など
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
            // 5. 12時を過ぎた場合
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('12時を過ぎた場合'),
                      content: const Text('12時を過ぎた場合のアクションをここに追加できます。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('12時を過ぎた場合'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
