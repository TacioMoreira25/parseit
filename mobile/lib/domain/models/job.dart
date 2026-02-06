import 'package:flutter/foundation.dart';

@immutable
class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final List<String> tags;
  final String url;
  final int salary;
  final String location;
  final DateTime createdAt;
  final String status; // Added status field

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.tags,
    required this.url,
    required this.salary,
    required this.location,
    required this.createdAt,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic tags) {
      if (tags is String && tags.isNotEmpty) {
        return tags
            .split(',')
            .map((tag) => tag.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }
      return [];
    }

    return Job(
      id: (json['ID'] as int).toString(),
      title: json['title'] as String? ?? 'No Title Provided',
      description: json['description'] as String? ?? 'No Description',
      company: json['company'] as String? ?? 'N/A',
      salary: json['salary'] as int? ?? 0,
      location: json['location'] as String? ?? 'Remote',
      tags: parseTags(json['tags']),
      url: json['link'] as String? ?? '',
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      status:
          json['status'] as String? ??
          'applied', // Default to 'applied' if null
    );
  }

  // Helper to create a new Job instance with an updated status.
  Job copyWith({String? status}) {
    return Job(
      id: id,
      title: title,
      company: company,
      description: description,
      tags: tags,
      url: url,
      salary: salary,
      location: location,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
