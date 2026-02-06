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

  /// Deletes a job by its ID.
  Future<void> deleteJob(String jobId) async {
    try {
      // The endpoint for DELETE is usually /jobs/{id}
      await _dio.delete('/jobs/$jobId');
    } on DioException {
      rethrow;
    }
  }

  /// Updates the status of a job.
  Future<void> updateStatus(String jobId, String newStatus) async {
    try {
      // The endpoint for PATCH is usually /jobs/{id}
      await _dio.patch('/jobs/$jobId', data: {'status': newStatus});
    } on DioException {
      rethrow;
    }
  }
}
