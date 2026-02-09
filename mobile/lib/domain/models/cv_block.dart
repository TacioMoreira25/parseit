import 'package:flutter/foundation.dart';

@immutable
class CVBlock {
  final String id;
  final String type;
  final Map<String, dynamic> content;

  const CVBlock({required this.id, required this.type, required this.content});

  factory CVBlock.createHeader({
    String? id,
    String name = '',
    String email = '',
  }) {
    return CVBlock(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'HEADER',
      content: {'name': name, 'email': email},
    );
  }

  factory CVBlock.createExperience({
    String? id,
    String company = '',
    String role = '',
    String period = '',
  }) {
    return CVBlock(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'EXPERIENCE',
      content: {'company': company, 'role': role, 'period': period},
    );
  }

  factory CVBlock.createText({String? id, String text = ''}) {
    return CVBlock(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'TEXT',
      content: {'text': text},
    );
  }

  CVBlock copyWith({String? id, String? type, Map<String, dynamic>? content}) {
    return CVBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }
}
