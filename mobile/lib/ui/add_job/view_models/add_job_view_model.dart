import 'package:flutter/material.dart';
import '../../../data/repositories/job_repository.dart';

class AddJobViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;

  // Controladores necessários para a UI
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AddJobViewModel(this._jobRepository);

  // Método solicitado pelo erro
  Future<bool> saveJob() async {
    if (titleController.text.isEmpty || companyController.text.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Aqui você chama o seu repositório para salvar
      // O repositório deve lidar com a extração de tags via backend
      await _jobRepository.createJob(
        titleController.text,
        companyController.text,
        descriptionController.text,
      );

      _clearInputs();
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar vaga: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearInputs() {
    titleController.clear();
    companyController.clear();
    descriptionController.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
