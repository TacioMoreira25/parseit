import 'package:flutter/material.dart';
import '../../../data/repositories/job_repository.dart';

class AddJobViewModel extends ChangeNotifier {
  final JobRepository _repository;

  AddJobViewModel(this._repository);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  String _selectedStatus = 'applied';
  String get selectedStatus => _selectedStatus;

  String _selectedJobType = 'Junior';
  String get selectedJobType => _selectedJobType;

  String _selectedLocation = 'Remoto';
  String get selectedLocation => _selectedLocation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Setters
  void setStatus(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void setJobType(String value) {
    _selectedJobType = value;
    notifyListeners();
  }

  void setLocation(String value) {
    _selectedLocation = value;
    notifyListeners();
  }

  Future<bool> saveJob() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.createJob(
        title: titleController.text,
        company: companyController.text,
        link: linkController.text,
        description: descriptionController.text,
        status: _selectedStatus,
        jobType: _selectedJobType,
        location: _selectedLocation,
        salary: salaryController.text,
      );
      _isLoading = false;
      _clearFields();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao salvar vaga: $e';
      notifyListeners();
      return false;
    }
  }

  void _clearFields() {
    titleController.clear();
    companyController.clear();
    descriptionController.clear();
    linkController.clear();
    salaryController.clear();
    _selectedStatus = 'applied';
    _selectedJobType = 'Junior';
    _selectedLocation = 'Remoto';
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    salaryController.dispose();
    super.dispose();
  }
}
