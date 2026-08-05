import 'package:dio/dio.dart';

import 'api_exception.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

/// Klien Dio dengan interceptor Bearer token dan parsing error terpusat.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  /// Eksekusi request dan konversi error Dio menjadi [ApiException].
  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  ApiException _parseError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 'Terjadi kesalahan.';
      final errors = <String, List<String>>{};
      final rawErrors = data['errors'];
      if (rawErrors is Map<String, dynamic>) {
        rawErrors.forEach((key, value) {
          errors[key] = value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()];
        });
      }
      return ApiException(message, statusCode: statusCode, errors: errors);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Koneksi ke server timeout. Coba lagi nanti.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Tidak dapat terhubung ke server. Pastikan server aktif.');
    }

    return ApiException(
      'Terjadi kesalahan (${statusCode ?? 'tidak diketahui'}).',
      statusCode: statusCode,
    );
  }
}
