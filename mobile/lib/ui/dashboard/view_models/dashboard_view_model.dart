import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/models/job.dart';

enum DashboardState { initial, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  final JobRepository _repository;

  DashboardViewModel(this._repository) {
    fetchJobs();
  }

  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  List<Job> _jobs = [];
  List<Job> get jobs => _jobs;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == DashboardState.loading;

  Timer? _pollingTimer;
  bool _isPollingActive = false;
  int _pollingAttempts = 0;
  final int _maxPollingAttempts = 100;

  Future<void> fetchJobs({bool showLoading = true}) async {
    if (showLoading) {
      _state = DashboardState.loading;
      notifyListeners();
    }

    try {
      _jobs = await _repository.fetchJobs();
      _state = DashboardState.success;

      _checkAndStartPollingIfNeeded();
    } catch (e) {
      _state = DashboardState.error;
      _errorMessage = 'Erro ao carregar vagas: $e';
    } finally {
      notifyListeners();
    }
  }

  void startTagPolling() {
    _pollingAttempts = 0;
    _startTimer();
  }

  void _checkAndStartPollingIfNeeded() {
    final hasPendingTags = _jobs.take(5).any((job) => job.tags.isEmpty);

    if (hasPendingTags) {
      if (!_isPollingActive) {
        if (_pollingAttempts < _maxPollingAttempts) {
          _startTimer();
        }
      }
    } else {
      stopPolling();
    }
  }

  void _startTimer() {
    _pollingTimer?.cancel();
    _isPollingActive = true;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_pollingAttempts >= _maxPollingAttempts) {
        stopPolling();
        return;
      }

      _pollingAttempts++;

      try {
        final newJobs = await _repository.fetchJobs();
        _jobs = newJobs;

        final hasPending = _jobs.take(5).any((job) => job.tags.isEmpty);
        if (!hasPending) {
          stopPolling();
        }
        notifyListeners();
      } catch (e) {
        print("Erro no polling (ignorado): $e");
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    _pollingAttempts = 0;
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await _repository.deleteJob(jobId);
      _jobs.removeWhere((job) => job.id == jobId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir vaga: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _repository.updateJobStatus(jobId, newStatus);
      fetchJobs(showLoading: false);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar status';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJobFull({
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
    try {
      await _repository.updateJob(
        jobId: jobId,
        title: title,
        company: company,
        link: link,
        description: description,
        status: status,
        jobType: jobType,
        location: location,
        salary: salary,
      );
      await fetchJobs(showLoading: false);
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao atualizar: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
