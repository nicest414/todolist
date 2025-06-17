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
  DateTime? notificationTime;
  DateTime? dueDate;
  bool notificationEnabled;

  TodoItem({
    required this.id,
    required this.title,
    this.memo = '',
    this.doneAt,
    this.isPinned = false,
    List<TodoChecklistItem>? checklist,
    this.notificationTime,
    this.dueDate,
    this.notificationEnabled = false,
  }) : checklist = checklist ?? [];

  TodoItem copyWith({
    String? id,
    String? title,
    String? memo,
    DateTime? doneAt,
    bool? isPinned,
    List<TodoChecklistItem>? checklist,
    DateTime? notificationTime,
    DateTime? dueDate,
    bool? notificationEnabled,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      doneAt: doneAt ?? this.doneAt,
      isPinned: isPinned ?? this.isPinned,
      checklist: checklist ?? this.checklist,
      notificationTime: notificationTime ?? this.notificationTime,
      dueDate: dueDate ?? this.dueDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  bool get isCompleted => doneAt != null;
}

enum TodoView { undone, done }

enum TodoType { continuous, single }
