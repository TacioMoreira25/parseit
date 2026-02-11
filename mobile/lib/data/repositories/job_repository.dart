// ignore_for_file: avoid_print

import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';
import '../services/api_service.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  Future<List<Job>> fetchJobs() async {
    final List<dynamic> jobData = await _apiService.fetchJobs();
    return jobData
        .map((json) => Job.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createJob({
    required String title,
    String? link,
    required String description,
  }) async {
    final data = {
      'title': title,
      'link': link ?? '',
      'description': description,
    };
    await _apiService.createJob(data);
  }

  Future<void> deleteJob(String jobId) async {
    await _apiService.deleteJob(jobId);
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    await _apiService.updateStatus(jobId, newStatus);
  }

  Future<void> updateJob({
    required String jobId,
    required String title,
    String? link,
    required String description,
  }) async {
    final data = {'title': title, 'link': link, 'description': description};
    data.removeWhere((key, value) => value == null);
    await _apiService.updateJob(jobId, data);
  }

  //// Looks up vocabulary for a list of tags.
  Future<List<VocabularyTerm>> lookupVocabulary(List<String> tags) async {
    if (tags.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = await _apiService.lookupVocabulary(tags);

      return data
          .map((json) => VocabularyTerm.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error no Repository: $e");
      rethrow;
    }
  }
}
