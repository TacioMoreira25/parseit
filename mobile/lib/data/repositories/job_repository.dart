import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';
import '../services/api_service.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  Future<List<Job>> fetchJobs() async {
    try {
      final List<dynamic> jobData = await _apiService.fetchJobs();
      return jobData
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erro ao buscar vagas: $e");
      throw Exception("Falha ao carregar vagas. Verifique sua conexão.");
    }
  }

  Future<void> createJob({
    required String title,
    required String company,
    required String link,
    required String description,
    required String status,
    required String jobType,
    required String location,
    required String salary,
  }) async {
    final data = {
      'title': title,
      'company': company,
      'link': link,
      'description': description,
      'status': status,
      'job_type': jobType,
      'location': location,
      'salary': salary,
    };
    await _apiService.createJob(data);
  }

  Future<void> updateJob({
    required String jobId,
    required String title,
    required String company,
    required String link,
    required String description,
    required String status,
    required String jobType,
    required String location,
    required String salary,
  }) async {
    final data = {
      'title': title,
      'company': company,
      'link': link,
      'description': description,
      'status': status,
      'job_type': jobType,
      'location': location,
      'salary': salary,
    };
    data.removeWhere((key, value) => value == null);

    await _apiService.updateJob(jobId, data);
  }

  Future<void> deleteJob(String jobId) async {
    await _apiService.deleteJob(jobId);
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    await _apiService.updateStatus(jobId, newStatus);
  }

  Future<List<VocabularyTerm>> lookupVocabulary(List<String> tags) async {
    if (tags.isEmpty) return [];
    try {
      final List<dynamic> data = await _apiService.lookupVocabulary(tags);
      return data
          .map((json) => VocabularyTerm.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erro no Repository (Vocabulário): $e");
      return [];
    }
  }
}
