import '../../domain/models/job.dart';
import '../services/api_service.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  Future<List<Job>> fetchJobs() async {
    try {
      final List<dynamic> jobData = await _apiService.fetchJobs();
      final List<Job> jobs = jobData
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createJob({
    required String title,
    String? link,
    required String description,
  }) async {
    try {
      final data = {
        'title': title,
        'link': link ?? '',
        'description': description,
      };
      await _apiService.createJob(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a job by its ID.
  Future<void> deleteJob(String jobId) async {
    try {
      await _apiService.deleteJob(jobId);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the status of a job.
  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _apiService.updateStatus(jobId, newStatus);
    } catch (e) {
      rethrow;
    }
  }
}
