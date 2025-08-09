class TodoChecklistItem {
  String title;
  bool isChecked;

  TodoChecklistItem(this.title, {this.isChecked = false});

  TodoChecklistItem copyWith({
    String? title,
    bool? isChecked,
  }) {
    return TodoChecklistItem(
      title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class TodoItem {
  final String id;
  String title;
  String memo;
  DateTime? doneAt;
  bool isPinned;
  List<TodoChecklistItem> checklist;
  List<String> tags;
  DateTime? notificationTime;
  DateTime? dueDate;
  bool notificationEnabled;
  int difficulty; // 1:簡単, 2:普通, 3:難しい, 4:困難

  TodoItem({
    required this.id,
    required this.title,
    this.memo = '',
    this.doneAt,
    this.isPinned = false,
    List<TodoChecklistItem>? checklist,
    List<String>? tags,
    this.notificationTime,
    this.dueDate,
    this.notificationEnabled = false,
    this.difficulty = 1,
  })  : checklist = checklist ?? [],
        tags = tags ?? [];

  TodoItem copyWith({
    String? id,
    String? title,
    String? memo,
    DateTime? doneAt,
    bool? isPinned,
    List<TodoChecklistItem>? checklist,
    List<String>? tags,
    DateTime? notificationTime,
    DateTime? dueDate,
    bool? notificationEnabled,
    int? difficulty,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      doneAt: doneAt ?? this.doneAt,
      isPinned: isPinned ?? this.isPinned,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
      notificationTime: notificationTime ?? this.notificationTime,
      dueDate: dueDate ?? this.dueDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  bool get isCompleted => doneAt != null;
}

enum TodoView { undone, done }

enum TodoType { continuous, single }
