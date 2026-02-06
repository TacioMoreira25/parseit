import 'package:dio/dio.dart';

/// A Dio client singleton for making network requests.
class DioClient {
  // Private constructor
  DioClient._();

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:8080/api/v1',
            connectTimeout: const Duration(seconds: 15), // Increased timeout
            receiveTimeout: const Duration(seconds: 10), // Increased timeout
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (o) => print(o),
          ),
        );

  /// Provides a singleton instance of Dio.
  static Dio get instance => _dio;
}
