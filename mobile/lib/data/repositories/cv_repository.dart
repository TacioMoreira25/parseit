import '../../domain/models/cv_block.dart';
import '../services/api_service.dart';

class CvRepository {
  final ApiService _apiService;

  CvRepository(this._apiService);

  Future<List<CVBlock>> fetchCvBlocks(String cvId) async {
    final data = await _apiService.fetchCvBlocks(cvId);
    return data.map((item) {
      // Assuming the API returns an 'id' for each block
      return CVBlock(
        id: item['id'].toString(),
        type: item['type'],
        content: Map<String, dynamic>.from(item['content']),
      );
    }).toList();
  }

  Future<void> addBlock(String cvId, CVBlock block) async {
    await _apiService.addBlock(cvId, block);
  }

  Future<void> updateBlockOrder(String cvId, List<CVBlock> blocks) async {
    final blockIds = blocks.map((b) => b.id).toList();
    await _apiService.updateBlockOrder(cvId, blockIds);
  }
}
