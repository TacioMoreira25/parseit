import 'package:dio/dio.dart';
import '../../config/dio_client.dart';

/// A service class for handling API requests.
class ApiService {
  final Dio _dio = DioClient.instance;

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

  /// Looks up vocabulary for a list of tags.
  Future<List<dynamic>> lookupVocabulary(List<String> tags) async {
    try {
      final response = await _dio.post(
        '/vocabulary/lookup',
        data: {'tags': tags},
      );
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to lookup vocabulary',
        );
      }
    } on DioException {
      rethrow;
    }
  }
}
