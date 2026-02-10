import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/cv_repository.dart';
import '../../../domain/models/cv_block.dart';

enum CvEditorStatus { loading, success, error }

class CvEditorViewModel extends ChangeNotifier {
  final CvRepository _repository;
  final String cvId;

  // --- ESTADO ---
  List<CVBlock> _blocks = [];
  List<CVBlock> get blocks => _blocks;

  CvEditorStatus _status = CvEditorStatus.loading;
  CvEditorStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // Controle de Modo (Leitura vs Edição)
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  Timer? _debounceTimer;

  // --- CONSTRUTOR ---
  CvEditorViewModel(this._repository, this.cvId) {
    _fetchCV();
  }

  // --- GETTERS & SETTERS ESPECIAIS ---

  // Retorna a fonte definida no Header (ou 'Inter' se não houver)
  String get currentFont {
    try {
      final header = _blocks.firstWhere((b) => b.type == 'HEADER');
      return header.content['fontFamily'] ?? 'Inter';
    } catch (_) {
      return 'Inter';
    }
  }

  // --- AQUI ESTAVA FALTANDO: Alterna entre modo de visualização e edição ---
  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  // --- MÉTODOS DE DADOS ---

  Future<void> _fetchCV() async {
    try {
      _status = CvEditorStatus.loading;
      notifyListeners();
      _blocks = await _repository.fetchCvBlocks(cvId);
      _status = CvEditorStatus.success;
    } catch (e) {
      _errorMessage = 'Erro ao carregar currículo: $e';
      _status = CvEditorStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // Salva a fonte escolhida no bloco HEADER
  void updateFont(String fontFamily) {
    final index = _blocks.indexWhere((b) => b.type == 'HEADER');
    if (index != -1) {
      final header = _blocks[index];
      // Atualiza localmente
      final newContent = Map<String, dynamic>.from(header.content);
      newContent['fontFamily'] = fontFamily;

      _blocks[index] = header.copyWith(content: newContent);
      notifyListeners();

      // Salva no backend
      _saveBlockContent(header.id, newContent);
    } else {
      _errorMessage = "Adicione um cabeçalho para alterar a fonte.";
      notifyListeners();
    }
  }

  Future<void> addBlock(String type) async {
    CVBlock newBlock;

    switch (type) {
      case 'HEADER':
        if (_blocks.any((b) => b.type == 'HEADER')) {
          _errorMessage = "O currículo já possui um cabeçalho.";
          notifyListeners();
          return;
        }
        newBlock = CVBlock.createHeader();
        break;
      case 'TEXT':
        newBlock = CVBlock.createText();
        break;
      case 'EXPERIENCE':
        newBlock = CVBlock.createExperience();
        break;
      case 'EDUCATION':
        newBlock = CVBlock.createEducation();
        break;
      case 'SKILL':
        newBlock = CVBlock.createSkill();
        break;
      case 'PROJECT':
        newBlock = CVBlock.createProject();
        break;
      default:
        return;
    }

    // UI Otimista
    _blocks.add(newBlock);
    notifyListeners();

    try {
      _setSaving(true);
      await _repository.addBlock(cvId, newBlock);
    } catch (e) {
      _blocks.removeLast();
      _errorMessage = "Erro ao adicionar seção.";
      notifyListeners();
    } finally {
      _setSaving(false);
    }
  }

  void updateBlock(String blockId, Map<String, dynamic> newContent) {
    final index = _blocks.indexWhere((b) => b.id == blockId);
    if (index == -1) return;

    // Atualiza apenas a memória local (sem notificar para não fechar teclado)
    _blocks[index] = _blocks[index].copyWith(content: newContent);

    // Debounce para salvar
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _saveBlockContent(blockId, newContent);
    });
  }

  Future<void> _saveBlockContent(
    String blockId,
    Map<String, dynamic> content,
  ) async {
    try {
      _setSaving(true);
      await _repository.updateBlock(cvId, blockId, content);
    } catch (e) {
      debugPrint("Erro ao salvar bloco: $e");
    } finally {
      _setSaving(false);
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _blocks.removeAt(oldIndex);
    _blocks.insert(newIndex, item);
    notifyListeners();

    _repository.updateBlockOrder(cvId, _blocks).catchError((e) {
      _errorMessage = "Erro ao reordenar.";
      notifyListeners();
    });
  }

  Future<void> deleteBlock(String blockId) async {
    final index = _blocks.indexWhere((b) => b.id == blockId);
    if (index == -1) return;

    final deleted = _blocks[index];
    _blocks.removeAt(index);
    notifyListeners();

    try {
      await _repository.deleteBlock(cvId, blockId);
    } catch (e) {
      _blocks.insert(index, deleted);
      _errorMessage = "Erro ao remover.";
      notifyListeners();
    }
  }

  Future<void> deleteCV() async {
    try {
      _setSaving(true);
      await _repository.deleteCV(cvId);
    } catch (e) {
      _errorMessage = "Erro ao deletar currículo.";
      notifyListeners();
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
