import '../../domain/models/cv_block.dart';
import '../services/api_service.dart';

class CvRepository {
  final ApiService _apiService;

  CvRepository(this._apiService);

  // Lista todos os CVs (Resumo)
  Future<List<Map<String, dynamic>>> fetchCVs() async {
    final data = await _apiService.fetchCVs();
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // Cria um novo CV e retorna o ID
  Future<String> createCV(String title) async {
    final data = await _apiService.createCV(title);
    return data['id'].toString();
  }

  // Busca os blocos de um CV específico
  Future<List<CVBlock>> fetchCvBlocks(String cvId) async {
    final data = await _apiService.fetchCvBlocks(cvId);
    return data.map((item) => CVBlock.fromJson(item)).toList();
  }

  Future<void> addBlock(String cvId, CVBlock block) async {
    await _apiService.addBlock(cvId, block);
  }

  Future<void> updateBlockOrder(String cvId, List<CVBlock> blocks) async {
    final blockIds = blocks.map((b) => b.id).toList();
    await _apiService.updateBlockOrder(cvId, blockIds);
  }

  Future<void> updateBlock(
    String cvId,
    String blockId,
    Map<String, dynamic> content,
  ) async {
    await _apiService.updateBlock(cvId, blockId, content);
  }

  Future<void> deleteBlock(String cvId, String blockId) async {
    await _apiService.deleteBlock(cvId, blockId);
  }

  Future<void> deleteCV(String cvId) async {
    await _apiService.deleteCV(cvId);
  }
}
