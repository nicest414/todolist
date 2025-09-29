import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  final TodoType initialType;

  const AddTodoDialog({
    super.key,
    required this.initialType,
  });

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final ScrollController _checklistScrollController = ScrollController();

  List<TodoChecklistItem> _tempChecklist = [];
  List<TextEditingController> _checklistControllers = [];
  DateTime? _notificationTime;
  DateTime? _dueDate;
  TodoType? _selectedType;
  int _difficulty = 1; // 1:簡単, 2:普通, 3:難しい, 4:困難
  // 追加: タグ入力（カンマ区切り）
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _checklistScrollController.dispose();
    for (final controller in _checklistControllers) {
      controller.dispose();
    }
    _tagsController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checklistScrollController.hasClients) {
        _checklistScrollController.animateTo(
          _checklistScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addChecklistItem() {
    setState(() {
      _tempChecklist.add(TodoChecklistItem(''));
      _checklistControllers.add(TextEditingController());
    });
    _scrollToEnd();
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _tempChecklist.removeAt(index);
      _checklistControllers[index].dispose();
      _checklistControllers.removeAt(index);
    });
  }

  Future<void> _selectNotificationTime() async {
    final now = DateTime.now();
    DateTime tempTime = _notificationTime ??
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                  _notificationTime = tempTime;
                });
                Navigator.of(context).pop();
              },
              child: const Text('決定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTodo() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // チェックリストの内容を更新
    for (int i = 0; i < _tempChecklist.length; i++) {
      _tempChecklist[i] = _tempChecklist[i].copyWith(
        title: _checklistControllers[i].text,
      );
    }

    final checklist =
        _tempChecklist.where((item) => item.title.isNotEmpty).toList();

    // タグのパース（カンマ区切り、空要素は除外、前後スペース除去、重複排除、小文字化はせず入力を尊重）
    final tags = _tagsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    if (_selectedType == TodoType.continuous) {
      ref.read(continuousTodoProvider.notifier).addTodo(
            title,
            memo: _memoController.text,
            checklist: checklist,
            tags: tags,
            notificationTime: _notificationTime,
            dueDate: _dueDate,
            difficulty: _difficulty, // 難易度を追加
          );
    } else {
      ref.read(singleTodoProvider.notifier).addTodo(
            title,
            memo: _memoController.text,
            checklist: checklist,
            tags: tags,
            notificationTime: _notificationTime,
            dueDate: _dueDate,
            difficulty: _difficulty, // 難易度を追加
          );
    }
    // 追加後に通知が設定されている場合は上部に MaterialBanner を表示する
    final hasNotification = _notificationTime != null;
    if (hasNotification) {
      // 一旦ダイアログを閉じてからバナーを表示すると UI が安定する
      Navigator.of(context).pop();

      // 少し遅延してバナーを表示（ダイアログのポップ処理が終わるのを待つ）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showMaterialBanner(MaterialBanner(
          content: Text('通知を有効にしたタスク「$title」を追加しました（${_notificationTime!.hour.toString().padLeft(2, '0')}:${_notificationTime!.minute.toString().padLeft(2, '0')}）'),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: const Text('閉じる'),
            ),
          ],
        ));

        // 自動で4秒後に消す
        Future.delayed(const Duration(seconds: 4), () {
          messenger.hideCurrentMaterialBanner();
        });
      });
      return;
    }

    // 通知が設定されている場合はダイアログを閉じてからバナーを表示し、通知音を再生する
    final hasNotification = _notificationTime != null;
    if (hasNotification) {
      // 通知がグローバルに許可されているか確認
      () async {
        final prefs = await SharedPreferences.getInstance();
        final bool globalAllowed = prefs.getBool('notification_enabled') ?? true;

        Navigator.of(context).pop();

        if (!globalAllowed) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showMaterialBanner(MaterialBanner(
            content: Text('通知を有効にしたタスク「$title」を追加しました（${_notificationTime!.hour.toString().padLeft(2, '0')}:${_notificationTime!.minute.toString().padLeft(2, '0')}）'),
            actions: [
              TextButton(
                onPressed: () => messenger.hideCurrentMaterialBanner(),
                child: const Text('閉じる'),
              ),
            ],
          ));

          // 非同期で通知音を再生（SharedPreferences の 'notification_volume' を参照）
          () async {
            try {
              final double notifVol = prefs.getDouble('notification_volume') ?? 0.5;
              final audioPlayer = AudioPlayer();
              await audioPlayer.play(AssetSource('audio/test.mp3'), volume: notifVol);
            } catch (e) {
              // ログのみ
              // ignore: avoid_print
              print('通知音の再生に失敗しました: $e');
            }
          }();

          // 4秒後に自動でバナーを非表示
          Future.delayed(const Duration(seconds: 4), () {
            messenger.hideCurrentMaterialBanner();
          });
        });
      }();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しいタスクを追加'),
      content: SingleChildScrollView(
        controller: _checklistScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'タスク内容',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '詳細メモ（任意）',
              ),
            ),
            const SizedBox(height: 12),
            // 追加: タグ入力
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'タグ（カンマ区切り）',
                hintText: '例: 仕事, 勉強, プライベート',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),

            // チェックリストセクション
            Row(
              children: [
                const Text('チェックリスト',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addChecklistItem,
                ),
              ],
            ),
            ...List.generate(_tempChecklist.length, (i) {
              return Row(
                children: [
                  Checkbox(
                    value: _tempChecklist[i].isChecked,
                    onChanged: (checked) {
                      setState(() {
                        _tempChecklist[i] = _tempChecklist[i].copyWith(
                          isChecked: checked ?? false,
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _checklistControllers[i],
                      decoration: const InputDecoration(
                        hintText: 'チェックリスト項目',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeChecklistItem(i),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // タイプ選択
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TodoType>(
                    title: const Text('継続'),
                    value: TodoType.continuous,
                    groupValue: _selectedType,
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),
                ),
                Expanded(
                  child: RadioListTile<TodoType>(
                    title: const Text('単発'),
                    value: TodoType.single,
                    groupValue: _selectedType,
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 通知時刻設定
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _notificationTime == null
                        ? '通知時刻を設定しない'
                        : '通知: ${_notificationTime!.hour.toString().padLeft(2, '0')}:${_notificationTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                TextButton(
                  onPressed: _selectNotificationTime,
                  child: const Text('時刻を設定'),
                ),
                if (_notificationTime != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _notificationTime = null),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 期限日設定
            Row(
              children: [
                const Icon(Icons.event, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? '期限日を設定しない'
                        : '期限: ${_dueDate!.year}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                TextButton(
                  onPressed: _selectDueDate,
                  child: const Text('日付を設定'),
                ),
                if (_dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _dueDate = null),
                  ),
              ],
            ),
            // 難易度設定
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text('難易度', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(4, (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: IconButton(
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(i+1, (j) => const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 19)),
                          ),
                          onPressed: () => setState(() => _difficulty = i+1),
                          color: _difficulty == i+1 ? Colors.deepOrange : Colors.grey,
                          tooltip: ['簡単','普通','難しい','困難'][i],
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    ['簡単','普通','難しい','困難'][_difficulty-1],
                    style: const TextStyle(fontSize: 14, color: Colors.deepOrange),
                  ),
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
          onPressed: _addTodo,
          child: const Text('追加'),
        ),
      ],
    );
  }
}
