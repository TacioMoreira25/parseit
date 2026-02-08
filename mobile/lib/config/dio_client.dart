import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A Dio client singleton for making network requests.
class DioClient {
  DioClient._();

  static String _getBaseUrl() {
    // A ordem importa. kIsWeb precisa vir primeiro.
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    if (Platform.isAndroid) {
      // Usa o IP especial para o Emulador Android.
      return 'http://10.0.2.2:8080/api/v1';
    }
    // Para todas as outras plataformas (Desktop Linux, Windows, macOS, iOS Simulator)
    // o localhost funciona.
    return 'http://localhost:8080/api/v1';
  }

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl:
                _getBaseUrl(), // Usa a função dinâmica para definir a URL base
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 10),
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
