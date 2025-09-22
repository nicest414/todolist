import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ユーザー管理Map
  Map<String, String> _registeredUsers = {};
  String? _loggedInEmail;
  String? _savedEmail;
  String? _savedPassword;

  // 起動時に読み込み
  @override
  void initState() {
    super.initState();
    loadUsers();
      loadSavedCredentials();
  }

    Future<void> loadSavedCredentials() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedEmail = prefs.getString('saved_email');
        _savedPassword = prefs.getString('saved_password');
      });
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

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: _savedEmail ?? '');
    final passwordController = TextEditingController(text: _savedPassword ?? '');
    bool isLogin = true;
    String? errorText;
    String? passwordErrorText;

    return Scaffold(
      appBar: AppBar(title: const Text('ログインページ')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(_loggedInEmail == null ? 'ログイン / 新規登録' : 'ログアウト'),
          onPressed: () async {
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
                              isLogin = !isLogin;
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

                            if (isLogin) {
                              // ログイン処理
                              if (_registeredUsers[email] == password) {
                                setState(() {
                                  _loggedInEmail = email;
                                });
                                  // ログイン成功時に保存
                                  final prefs = await SharedPreferences.getInstance();
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
                                // 新規登録時にも保存
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('saved_email', email);
                                await prefs.setString('saved_password', password);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('登録が完了しました。ログインしてください')),
                              );
                              setState(() {
                                isLogin = true;
                                errorText = null;
                                passwordErrorText = null;
                                emailController.clear();
                                passwordController.clear();
                              });
                            } // ←ここが不足していた！
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
        ),
      ),
    );
}

