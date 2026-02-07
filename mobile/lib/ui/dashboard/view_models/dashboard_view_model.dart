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
      _jobs.removeWhere((job) => job.id == jobId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting job: $e');
      _errorMessage = 'Failed to delete job.';
      return false;
    }
  }

  Future<bool> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _jobRepository.updateJobStatus(jobId, newStatus);
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

  /// Updates the core details of a job.
  Future<bool> updateJobDetails({
    required String jobId,
    required String title,
    String? link,
    required String description,
  }) async {
    try {
      await _jobRepository.updateJob(
        jobId: jobId,
        title: title,
        link: link,
        description: description,
      );
      // For a complete refresh to get all updated data from server:
      await fetchJobs();
      return true;
    } catch (e) {
      debugPrint('Error updating job details: $e');
      _errorMessage = 'Failed to update job details.';
      return false;
    }
  }
}
