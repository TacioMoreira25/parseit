class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String url;
  final String status;
  final List<String> tags;
  final String jobType;
  final String location;
  final String salary;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.url,
    required this.status,
    required this.tags,
    this.jobType = 'Não especificado',
    this.location = 'Não especificado',
    this.salary = '',
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic tagsInput) {
      if (tagsInput is String) {
        if (tagsInput.isEmpty) return [];
        return tagsInput
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (tagsInput is List) {
        // Se já for lista, apenas converte
        return List<String>.from(tagsInput);
      }
      return [];
    }

    return Job(
      id: json['id']?.toString() ?? json['ID']?.toString() ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      url: json['link'] ?? '',
      status: json['status'] ?? 'applied',
      tags: parseTags(json['tags']),
      jobType: json['job_type'] ?? 'Integral',
      location: json['location'] ?? 'Remoto',
      salary: json['salary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'description': description,
      'link': url,
      'status': status,
      'tags': tags,
      'job_type': jobType,
      'location': location,
      'salary': salary,
    };
  }
}
