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

  List<Job> _jobs = [];
  List<Job> get jobs => _jobs;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchJobs() async {
    _state = DashboardState.loading;
    notifyListeners();

    try {
      _jobs = await _jobRepository.fetchJobs();
      _state = DashboardState.success;
    } catch (e) {
      _state = DashboardState.error;
      _errorMessage = 'Failed to load jobs. Please try again later.';
      debugPrint('Error fetching jobs: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await _jobRepository.deleteJob(jobId);

      // Remove from local list for instant UI update
      _jobs.removeWhere((job) => job.id == jobId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting job: $e');
      _errorMessage = 'Failed to delete job.';
      // Optionally, set state to error and notify listeners
      return false;
    }
  }

  Future<bool> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _jobRepository.updateJobStatus(jobId, newStatus);

      // Find and update the job in the local list
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(status: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating job status: $e');
      _errorMessage = 'Failed to update job status.';
      return false;
    }
  }
}
