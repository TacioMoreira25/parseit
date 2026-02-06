import 'package:flutter/material.dart';
import '../../../data/repositories/job_repository.dart';

enum AddJobState { idle, loading, success, error }

class AddJobViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  AddJobViewModel(this._jobRepository);

  final titleController = TextEditingController();
  final linkController = TextEditingController();
  final descriptionController = TextEditingController();

  AddJobState _state = AddJobState.idle;
  AddJobState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> submitJob() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      _errorMessage = 'Título e Descrição são obrigatórios.';
      notifyListeners();
      return false;
    }

    _state = AddJobState.loading;
    notifyListeners();

    try {
      await _jobRepository.createJob(
        title: titleController.text,
        link: linkController.text,
        description: descriptionController.text,
      );

      _state = AddJobState.success;
      notifyListeners();

      _clearForm();
      _state = AddJobState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao enviar a vaga. Tente novamente.';
      _state = AddJobState.error;
      notifyListeners();
      return false;
    } finally {
      if (_state == AddJobState.loading) {
        _state = AddJobState.idle;
        notifyListeners();
      }
    }
  }

  void _clearForm() {
    titleController.clear();
    linkController.clear();
    descriptionController.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
