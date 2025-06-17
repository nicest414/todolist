## 📱 アプリ概要

このアプリは5つの主要なタブから構成されています：
- **実績** - 完了したタスクの実績を表示
- **TODO継続** - 継続的に取り組むタスク管理
- **すごろく** - ゲーミフィケーション機能
- **TODO単発** - 一回限りのタスク管理
- **マイページ** - ユーザー設定とプロフィール

## 🏗️ プロジェクト構造

```
lib/
├── main.dart                    # アプリケーションエントリーポイント
├── models/                      # データモデル
│   └── todo_item.dart          # TODOアイテムとチェックリストの定義
├── providers/                   # 状態管理（Riverpod）
│   └── todo_provider.dart      # TODO状態の管理
├── screens/                     # 画面コンポーネント
│   ├── home_screen.dart        # メイン画面（タブナビゲーション）
│   ├── achievements_tab.dart   # 実績タブ
│   ├── continuous_todo_tab.dart # 継続TODOタブ
│   ├── sugoroku_tab.dart       # すごろくタブ
│   ├── single_todo_tab.dart    # 単発TODOタブ
│   └── my_page_tab.dart        # マイページタブ
├── widgets/                     # 再利用可能なウィジェット
│   ├── todo_item_widget.dart   # TODOアイテム表示ウィジェット
│   └── add_todo_dialog.dart    # TODO追加ダイアログ
└── legacy/                      # 旧バージョンのファイル
    ├── home_screen.dart        # 旧ホーム画面
    └── home_screen_souta.dart  # 旧ホーム画面（別バージョン）
```

## 🛠️ 技術スタック

- **Framework**: Flutter 3.0+
- **言語**: Dart
- **状態管理**: Flutter Riverpod 2.4.9
- **Code Generation**: Riverpod Generator 2.3.9
- **Build Runner**: 2.4.7
- **デザインプレビュー**: Device Preview 1.1.0

## 📋 主要機能

### TODOアイテム機能
- ✅ タスクの作成・編集・削除
- 📌 重要なタスクのピン留め
- 📝 メモ機能
- ☑️ チェックリスト機能
- 🔔 通知設定
- 📅 期限設定
- 🔄 継続タスクと単発タスクの分類

### データモデル
- **TodoItem**: メインのTODOアイテム
  - ID、タイトル、メモ
  - 完了状態、ピン状態
  - 通知時間、期限
  - チェックリスト
- **TodoChecklistItem**: チェックリストの個別アイテム
- **TodoView**: 表示モード（完了/未完了）
- **TodoType**: タスクタイプ（継続/単発）

## 🚀 セットアップ

### 前提条件
- Flutter SDK 3.0.0 以上
- Dart SDK 3.0.0 以上

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone <repository-url>
   cd todolist
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **コード生成の実行**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **アプリケーションの実行**
   ```bash
   flutter run
   ```

## 🔧 開発環境

### 推奨IDE設定
- **Visual Studio Code** with Flutter extension
- **Android Studio** with Flutter plugin

### 有用なコマンド

```bash
# 依存関係の更新
flutter pub get

# コード生成
flutter packages pub run build_runner build

# 継続的なコード生成（開発時）
flutter packages pub run build_runner watch

# 静的解析の実行
flutter analyze

# テストの実行
flutter test

# ビルド（Android）
flutter build apk

# ビルド（iOS）
flutter build ios
```

## 📁 ファイル作成のガイドライン

### 新しい画面の追加
1. `lib/screens/` に新しいファイルを作成
2. `ConsumerStatefulWidget` または `ConsumerWidget` を継承
3. `home_screen.dart` にタブとして追加

### 新しいウィジェットの追加
1. `lib/widgets/` に新しいファイルを作成
2. 再利用可能なコンポーネントとして設計
3. 適切なプロパティとコンストラクタを定義

### 状態管理の追加
1. `lib/providers/` に新しいプロバイダーを作成
2. Riverpod の `StateNotifier` を使用
3. 必要に応じて `riverpod_annotation` を使用

### データモデルの追加
1. `lib/models/` に新しいモデルを作成
2. `copyWith` メソッドを実装
3. 必要に応じて JSON シリアライゼーションを追加

## 🔍 コード品質

### Linting
プロジェクトは `flutter_lints` を使用して、Flutterの推奨コーディング規約に従っています。

### 主要なルール
- `prefer_const_constructors`: パフォーマンス向上のため定数コンストラクタを使用
- `unused_element`: 未使用の要素を削除
- `file_names`: ファイル名はlower_case_with_underscoresを使用

## 🐛 トラブルシューティング

### よくある問題

1. **flutter_lints が見つからない**
   ```bash
   flutter pub add --dev flutter_lints
   flutter pub get
   ```

2. **ビルドエラー**
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build
   ```

3. **デバイスプレビューが動作しない**
   - `device_preview` パッケージが正しくインストールされているか確認
   - デバッグモードで実行しているか確認

## 📊 Git管理

### ブランチ戦略
- `main`: 本番用ブランチ
- `develop`: 開発用ブランチ
- `feature/*`: 機能開発用ブランチ

### コミットメッセージ規約
```
feat: 新機能の追加
fix: バグ修正
docs: ドキュメントの更新
style: コードフォーマットの変更
refactor: リファクタリング
test: テストの追加・修正
```

### 推奨ファイル管理
- 大きなファイルは適切に分割
- 未使用のファイルは `legacy/` フォルダに移動
- 定期的にコードレビューを実施

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 📞 サポート

問題や質問がある場合は、GitHubのIssuesを作成してください。

---

**最終更新**: 2025年6月17日
