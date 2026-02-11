import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';
import '../services/api_service.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  /// Renomeado para getJobs para coincidir com a chamada no DashboardViewModel
  Future<List<Job>> getJobs() async {
    try {
      final List<dynamic> jobData = await _apiService.fetchJobs();
      return jobData
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erro ao buscar vagas no Repository: $e");
      return [];
    }
  }

  /// Ajustado para aceitar parâmetros posicionais ou nomeados conforme o AddJobViewModel chamou
  Future<void> createJob(
    String title,
    String company,
    String description,
  ) async {
    final data = {
      'title': title,
      'company': company, // Adicionado campo company que estava faltando
      'description': description,
    };

    try {
      await _apiService.createJob(data);
    } catch (e) {
      print("Erro ao criar vaga no Repository: $e");
      rethrow;
    }
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
    String? company,
    required String description,
  }) async {
    final data = {
      'title': title,
      'company': company,
      'description': description,
    };
    data.removeWhere((key, value) => value == null);
    await _apiService.updateJob(jobId, data);
  }

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
      print("Error no Repository (Vocabulary): $e");
      rethrow;
    }
  }
}
