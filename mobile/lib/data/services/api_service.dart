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

  Future<List<dynamic>> fetchCvBlocks(String cvId) async {
    try {
      final response = await _dio.get(
        '/cvs/$cvId',
      ); // Assuming endpoint returns a CV object with a 'blocks' list
      if (response.statusCode == 200 && response.data['blocks'] is List) {
        return response.data['blocks'] as List;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to load CV blocks',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  Future<void> addBlock(String cvId, CVBlock block) async {
    try {
      await _dio.post(
        '/cvs/$cvId/blocks',
        data: {'type': block.type, 'content': block.content},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateBlockOrder(String cvId, List<String> blockIds) async {
    try {
      await _dio.put('/cvs/$cvId/order', data: {'block_ids': blockIds});
    } on DioException {
      rethrow;
    }
  }

  // NOTE: PDF generation is a GET request that should probably be handled
  // by a URL launcher, so no specific ApiService method for it.
}
