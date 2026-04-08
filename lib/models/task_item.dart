enum RepeatType { once, daily, alternate, custom }

RepeatType repeatTypeFromString(String value) {
  return RepeatType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => RepeatType.once,
  );
}

class TaskItem {
  final String id;
  final String userId;
  final String title;
  final List<String> steps;
  final bool isCompleted;
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;
  final RepeatType repeatType;
  final List<int> repeatDays;
  final DateTime? completedDate;

  const TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.steps,
    required this.isCompleted,
    required this.groupId,
    required this.startDate,
    required this.endDate,
    required this.repeatType,
    required this.repeatDays,
    required this.completedDate,
  });

  TaskItem copyWith({
    String? id,
    String? userId,
    String? title,
    List<String>? steps,
    bool? isCompleted,
    String? groupId,
    DateTime? startDate,
    DateTime? endDate,
    RepeatType? repeatType,
    List<int>? repeatDays,
    DateTime? completedDate,
    bool clearCompletedDate = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
      groupId: groupId ?? this.groupId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      completedDate: clearCompletedDate ? null : completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'steps': steps,
      'isCompleted': isCompleted,
      'groupId': groupId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'repeatType': repeatType.name,
      'repeatDays': repeatDays,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      steps: ((map['steps'] as List?) ?? []).map((e) => e.toString()).toList(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      groupId: map['groupId'] as String? ?? '',
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      repeatType: repeatTypeFromString(map['repeatType'] as String? ?? 'once'),
      repeatDays: ((map['repeatDays'] as List?) ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 1)
          .toList(),
      completedDate: map['completedDate'] == null
          ? null
          : DateTime.tryParse(map['completedDate'] as String),
    );
  }
}
