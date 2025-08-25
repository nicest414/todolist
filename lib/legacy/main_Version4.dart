import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart'; // ← 追加

void main() {
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

// ↓ここをConsumerWidgetに変更
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // themeModeProviderの値を監視
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TODOリスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light, // 明示的に
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark, // 明示的に
      ),
      themeMode: themeMode, // ← ここが超重要！！！
      home: const TodoListPage(),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}