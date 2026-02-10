import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class CVBlock {
  final String id;
  final String type;
  final Map<String, dynamic> content;
  final int position;

  const CVBlock({
    required this.id,
    required this.type,
    required this.content,
    this.position = 0,
  });

  factory CVBlock.createHeader() => CVBlock(
    id: _uuid.v4(),
    type: 'HEADER',
    content: {'name': '', 'email': '', 'linkedin': '', 'location': ''},
  );

  factory CVBlock.createText() =>
      CVBlock(id: _uuid.v4(), type: 'TEXT', content: {'text': '', 'title': ''});

  factory CVBlock.createExperience() => CVBlock(
    id: _uuid.v4(),
    type: 'EXPERIENCE',
    content: {'company': '', 'role': '', 'period': '', 'description': ''},
  );

  factory CVBlock.createEducation() => CVBlock(
    id: _uuid.v4(),
    type: 'EDUCATION',
    content: {'institution': '', 'degree': '', 'period': ''},
  );

  factory CVBlock.createSkill() =>
      CVBlock(id: _uuid.v4(), type: 'SKILL', content: {'skills': ''});

  factory CVBlock.createProject() => CVBlock(
    id: _uuid.v4(),
    type: 'PROJECT',
    content: {'title': '', 'description': '', 'link': ''},
  );

  factory CVBlock.fromJson(Map<String, dynamic> json) {
    return CVBlock(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'UNKNOWN',
      content: json['content'] != null
          ? Map<String, dynamic>.from(json['content'])
          : {},
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'content': content,
    'position': position,
  };

  CVBlock copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? content,
    int? position,
  }) {
    return CVBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
    );
  }
}
