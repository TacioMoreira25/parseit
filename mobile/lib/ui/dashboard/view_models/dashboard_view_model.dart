import 'package:flutter/foundation.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/models/job.dart';

enum DashboardState { initial, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;

  DashboardViewModel(this._jobRepository) {
    fetchJobs();
  }

  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  bool get isLoading => _state == DashboardState.loading;

  List<Job> _jobs = [];
  List<Job> get jobs => _jobs;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchJobs() async {
    _state = DashboardState.loading;
    notifyListeners();

    try {
      _jobs = await _jobRepository.getJobs(); // Sincronizado com o Repository
      _state = DashboardState.success;
    } catch (e) {
      _state = DashboardState.error;
      _errorMessage = 'Falha ao carregar vagas.';
      debugPrint('Error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await _jobRepository.deleteJob(jobId);
      _jobs.removeWhere((job) => job.id == jobId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateJobDetails({
    required String jobId,
    required String title,
    String? company, // Alterado aqui
    required String description,
  }) async {
    try {
      await _jobRepository.updateJob(
        jobId: jobId,
        title: title,
        company: company,
        description: description,
      );
      await fetchJobs();
      return true;
    } catch (e) {
      debugPrint('Error updating job: $e');
      return false;
    }
  }
}
