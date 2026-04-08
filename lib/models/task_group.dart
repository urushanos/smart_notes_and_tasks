import 'package:flutter/material.dart';

class TaskGroup {
  final String id;
  final String name;
  final String userId;
  final String colorHex;

  const TaskGroup({
    required this.id,
    required this.name,
    required this.userId,
    required this.colorHex,
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xff')));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'color': colorHex,
    };
  }

  factory TaskGroup.fromMap(Map<String, dynamic> map) {
    return TaskGroup(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed',
      userId: map['userId'] as String? ?? '',
      colorHex: map['color'] as String? ?? '#4CAF50',
    );
  }
}
