import 'package:dio/dio.dart';
import '../../config/dio_client.dart';
import '../../domain/models/cv_block.dart';

class ApiService {
  final Dio _dio = DioClient.instance;

  // ... existing job methods ...

  Future<List<dynamic>> fetchJobs() async {
    try {
      final response = await _dio.get('/jobs');
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to load jobs',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      await _dio.post('/jobs', data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _dio.delete('/jobs/$jobId');
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateStatus(String jobId, String newStatus) async {
    try {
      await _dio.patch('/jobs/$jobId/status', data: {'status': newStatus});
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await _dio.patch('/jobs/$jobId', data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<List<dynamic>> lookupVocabulary(List<String> tags) async {
    try {
      final response = await _dio.post(
        '/vocabulary/lookup',
        data: {"terms": tags},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      } else {
        return [];
      }
    } on DioException {
      rethrow;
    }
  }

  // --- CV Methods ---

  Future<List<dynamic>> fetchCVs() async {
    try {
      final response = await _dio.get('/cvs');
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCV(String title) async {
    try {
      final response = await _dio.post('/cvs', data: {'title': title});
      return response.data; // Espera retornar o objeto CV criado com ID
    } on DioException {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchCvBlocks(String cvId) async {
    try {
      final response = await _dio.get('/cvs/$cvId');
      // O backend deve retornar o objeto CV com uma chave 'blocks'
      if (response.statusCode == 200 && response.data['blocks'] is List) {
        return response.data['blocks'] as List;
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<void> addBlock(String cvId, CVBlock block) async {
    try {
      await _dio.post(
        '/cvs/$cvId/blocks',
        data: block.toJson(), // Usa o toJson que criamos
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateBlockOrder(String cvId, List<String> blockIds) async {
    try {
      // Endpoint específico para reordenação em lote
      await _dio.post('/cvs/$cvId/reorder', data: {'block_ids': blockIds});
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateBlock(
    String cvId,
    String blockId,
    Map<String, dynamic> content,
  ) async {
    try {
      // Endpoint: PATCH /cvs/:id/blocks/:blockId
      await _dio.patch(
        '/cvs/$cvId/blocks/$blockId',
        data: {'content': content},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> deleteBlock(String cvId, String blockId) async {
    try {
      // Endpoint: DELETE /cvs/:id/blocks/:blockId
      await _dio.delete('/cvs/$cvId/blocks/$blockId');
    } on DioException {
      rethrow;
    }
  }

  Future<void> deleteCV(String cvId) async {
    try {
      // Endpoint: DELETE /cvs/:id
      await _dio.delete('/cvs/$cvId');
    } on DioException {
      rethrow;
    }
  }
}
