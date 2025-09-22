import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_2/models/todo_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/todo_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_2/providers/theme_provider.dart'; // ← これを必ず追加

Map<String, String> _registeredUsers = {};

class MyPageTab extends ConsumerStatefulWidget {
  const MyPageTab({super.key});

  @override
  ConsumerState<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends ConsumerState<MyPageTab> {
  String _profileName = '';
  String _profileBio = '';
  String? _loggedInEmail;

  // 通知ON/OFF状態
  bool _notificationEnabled = true;
  bool _todoNotificationSettingEnabled = false;
  bool _todoNotificationEnabled = false;

  // 通知プラグインのインスタンス
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer(); // クラスのフィールドに追加

  // bool _isDarkMode = false; // ← もう不要なのでコメントアウトまたは削除
  double _appVolume = 0.5; // ← 追加: アプリ音量を保持
  double _notificationVolume = 0.5; // ← 追加: 通知音量を保持

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
      loadLoggedInEmail();
      loadUsers();
 // 通知設定をロード
      _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _todoNotificationSettingEnabled = prefs.getBool('todo_notification_setting_enabled') ?? false;
      _todoNotificationEnabled = prefs.getBool('todo_notification_enabled') ?? false;
      // 既存のボリューム設定も prefs から読み込める（オプション）
      _appVolume = prefs.getDouble('app_volume') ?? _appVolume;
      _notificationVolume = prefs.getDouble('notification_volume') ?? _notificationVolume;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _notificationEnabled);
    await prefs.setBool('todo_notification_setting_enabled', _todoNotificationSettingEnabled);
    await prefs.setBool('todo_notification_enabled', _todoNotificationEnabled);
    await prefs.setDouble('app_volume', _appVolume);
    await prefs.setDouble('notification_volume', _notificationVolume);
  }

  // セッターを用意して親 state を確実に更新しつつ永続化する
  void _setNotificationEnabled(bool val) {
    setState(() {
      _notificationEnabled = val;
    });
    _saveNotificationSettings();
  }

  void _setTodoNotificationSettingEnabled(bool val) {
    setState(() {
      _todoNotificationSettingEnabled = val;
    });
    _saveNotificationSettings();
  }

  void _setTodoNotificationEnabled(bool val) {
    setState(() {
      _todoNotificationEnabled = val;
    });
    _saveNotificationSettings();
  }


    Future<void> loadUsers() async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('users');
      if (jsonString != null) {
        setState(() {
          _registeredUsers = Map<String, String>.from(jsonDecode(jsonString));
        });
      }
    }

    Future<void> saveUsers() async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_registeredUsers);
      await prefs.setString('users', jsonString);
    }
    Future<void> loadLoggedInEmail() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _loggedInEmail = prefs.getString('saved_email');
      });
    }
  Future<void> showLocalNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'todo_channel',
      'TODO通知',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'TODOリマインダー',
      'タスクの通知です',
      platformChannelSpecifics,
    );
  }

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
      String? errorText;
      String? passwordErrorText;
      bool isLogin = true; // ←追加: ログイン/新規登録の切替

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(isLogin ? 'ログイン' : '新規登録'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'メールアドレス',
                        errorText: errorText,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        errorText: passwordErrorText,
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin; // ←「ログイン/新規登録」切り替え
                        errorText = null;
                        passwordErrorText = null;
                        emailController.clear();
                        passwordController.clear();
                      });
                    },
                    child: Text(isLogin ? '新規登録はこちら' : 'ログインはこちら'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        final validEmail = email.endsWith('@gmail.com') ||
                            email.endsWith('@outlook.com') ||
                            email.endsWith('@icloud.com');
                        final validPassword = password.length >= 5 && password.length <= 12;

                        bool hasError = false;

                        if (!validEmail) {
                          setState(() {
                            errorText = 'メールアドレスは@gmail.com/@outlook.com/@icloud.comのいずれかで終わる必要があります';
                          });
                          hasError = true;
                        } else {
                          setState(() {
                            errorText = null;
                          });
                        }

                        if (!validPassword) {
                          setState(() {
                            passwordErrorText = 'パスワードは5〜12文字で入力してください';
                          });
                          hasError = true;
                        } else {
                          setState(() {
                            passwordErrorText = null;
                          });
                        }

                        if (hasError) return;

                        final prefs = await SharedPreferences.getInstance();
                        if (isLogin) {
                            // ログイン処理（登録済みユーザーのみ許可）
                            if (_registeredUsers.containsKey(email) && _registeredUsers[email] == password) {
                              this.setState(() {
                                _loggedInEmail = email;
                              });
                              await prefs.setString('saved_email', email);
                              await prefs.setString('saved_password', password);
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                errorText = '登録情報がありません、またはパスワードが間違っています';
                              });
                            }
                        } else {
                            // 新規登録処理
                            if (_registeredUsers.containsKey(email)) {
                              setState(() {
                                errorText = 'このメールアドレスは既に登録されています';
                              });
                              return;
                            }
                            _registeredUsers[email] = password;
                            await saveUsers();
                            await prefs.setString('saved_email', email);
                            await prefs.setString('saved_password', password);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('登録が完了しました。ログインしてください')),
                            );
                            setState(() {
                              isLogin = true; // 登録後はログイン画面に戻す
                            });
                        }
                      },
                    child: Text(isLogin ? 'ログイン' : '登録'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
    child: const Text('ログイン'),
  ),
),
            const SizedBox(height: 24),
            // 2. プロフィール編集
            if (_loggedInEmail != null)
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('通知・リマインダー'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SwitchListTile(
                                                  title: const Text('通知'),
                                                  value: _notificationEnabled,
                                                  onChanged: (val) {
                                                    // ダイアログ内部からも親のセッターを呼ぶ
                                                    setState(() {
                                                      _notificationEnabled = val;
                                                    });
                                                    _setNotificationEnabled(val);
                                                  },
                                                ),
                                                SwitchListTile(
                                                  title: const Text('todoごとの通知設定'),
                                                  value: _todoNotificationSettingEnabled,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _todoNotificationSettingEnabled = val;
                                                    });
                                                    _setTodoNotificationSettingEnabled(val);
                                                  },
                                                ),
                                                SwitchListTile(
                                                  title: const Text('todoごとの通知'),
                                                  value: _todoNotificationEnabled,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _todoNotificationEnabled = val;
                                                    });
                                                    _setTodoNotificationEnabled(val);
                                                  },
                                                ),
                                                const SizedBox(height: 16),                                                
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
                                  );
                                },
                                child: const Text('通知・リマインダー'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      ThemeMode tempThemeMode = ref.read(themeModeProvider);
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('外観・デザイン設定'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                RadioListTile<ThemeMode>(
                                                  title: const Text('ライトモード'),
                                                  value: ThemeMode.light,
                                                  groupValue: tempThemeMode,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      tempThemeMode = ThemeMode.light;
                                                    });
                                                  },
                                                ),
                                                RadioListTile<ThemeMode>(
                                                  title: const Text('ダークモード'),
                                                  value: ThemeMode.dark,
                                                  groupValue: tempThemeMode,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      tempThemeMode = ThemeMode.dark;
                                                    });
                                                  },
                                                ),
                                                RadioListTile<ThemeMode>(
                                                  title: const Text('システムに合わせる'),
                                                  value: ThemeMode.system,
                                                  groupValue: tempThemeMode,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      tempThemeMode = ThemeMode.system;
                                                    });
                                                  },
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
                                                  ref.read(themeModeProvider.notifier).state = tempThemeMode;
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        tempThemeMode == ThemeMode.dark
                                                            ? 'ダークモードに切り替えました'
                                                            : tempThemeMode == ThemeMode.light
                                                                ? 'ライトモードに切り替えました'
                                                                : 'システム設定に合わせました',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('決定'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
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
                                  // ダイアログ表示時に現在の値で初期化
                                  double volume = _appVolume;
                                  double notificationVolume = _notificationVolume;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('サウンド・バイブ設定'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('アプリの音量を調節'),
                                                Slider(
                                                  value: volume,
                                                  min: 0.0,
                                                  max: 1.0,
                                                  divisions: 10,
                                                  label: '${(volume * 100).round()}%',
                                                  onChanged: (val) {
                                                    setState(() {
                                                      volume = val;
                                                    });
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await _audioPlayer.play(
                                                      AssetSource('audio/test.mp3'),
                                                      volume: volume,
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('アプリ音量 ${(volume * 100).round()}% でテスト再生！'),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('アプリ音量テスト'),
                                                ),
                                                const SizedBox(height: 16),
                                                const Text('通知音の大きさを調節'),
                                                Slider(
                                                  value: notificationVolume,
                                                  min: 0.0,
                                                  max: 1.0,
                                                  divisions: 10,
                                                  label: '${(notificationVolume * 100).round()}%',
                                                  onChanged: (val) {
                                                    setState(() {
                                                      notificationVolume = val;
                                                    });
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await _audioPlayer.play(
                                                      AssetSource('audio/test.mp3'),
                                                      volume: notificationVolume,
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('通知音量 ${(notificationVolume * 100).round()}% でテスト再生！'),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('通知音量テスト'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('閉じる'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // ダイアログで調整した値をクラスのフィールドに保存
                                                  setState(() {
                                                    _appVolume = volume;
                                                    _notificationVolume = notificationVolume;
                                                  });
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('音量設定を保存しました')),
                                                  );
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

            // ↓ここを追加
            if (_loggedInEmail != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _loggedInEmail = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ログアウトしました')),
                    );
                  },
                  child: const Text('ログアウト'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}