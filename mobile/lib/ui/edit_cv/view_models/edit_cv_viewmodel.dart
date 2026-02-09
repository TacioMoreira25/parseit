import 'package:flutter/material.dart';
import '../../../data/repositories/cv_repository.dart';
import '../../../domain/models/cv_block.dart';

class EditCvViewModel extends ChangeNotifier {
  final CvRepository _cvRepository;
  // This would likely come from navigation arguments in a real app.
  final String _currentCvId = "1"; // Example CV ID

  List<CVBlock> _blocks = [];
  bool _isLoading = false;
  String? _error;

  EditCvViewModel(this._cvRepository);

  List<CVBlock> get blocks => _blocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCvBlocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blocks = await _cvRepository.fetchCvBlocks(_currentCvId);
    } catch (e) {
      _error = "Failed to load CV. Please try again.";
      print(e); // For debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBlock(CVBlock block) async {
    _blocks.add(block);
    notifyListeners();

    try {
      await _cvRepository.addBlock(_currentCvId, block);
    } catch (e) {
      _error = "Failed to add block. Reverting.";
      _blocks.remove(block);
      notifyListeners();
    }
  }

  Future<void> onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _blocks.removeAt(oldIndex);
    _blocks.insert(newIndex, item);
    notifyListeners();

    try {
      await _cvRepository.updateBlockOrder(_currentCvId, _blocks);
    } catch (e) {
      _error = "Failed to save new order. Please try again.";
      notifyListeners();
    }
  }

  void updateBlockContent(String id, Map<String, dynamic> newContent) {
    final index = _blocks.indexWhere((b) => b.id == id);
    if (index != -1) {
      _blocks[index] = _blocks[index].copyWith(content: newContent);
      // TODO: Implement backend call for content update (debounced)
      notifyListeners();
    }
  }

  Future<void> generateAndOpenPdf() async {
    print('Generating and opening PDF...');
  }
}
