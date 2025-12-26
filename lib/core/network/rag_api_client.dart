import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../models/rag_models.dart';

/// Exception for RAG API errors
class RagApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  RagApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'RagApiException: $message (status: $statusCode)';
}

/// API client for local Python RAG server
class RagApiClient {
  late final Dio _dio;
  final String baseUrl;

  RagApiClient({String? baseUrl}) : baseUrl = baseUrl ?? Env.ragServerUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: this.baseUrl,
        connectTimeout: Duration(seconds: Env.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: Env.apiTimeoutSeconds),
        sendTimeout: Duration(seconds: Env.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🤖 RAG Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RAG Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ RAG Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Check RAG server health
  Future<RagHealthResponse> healthCheck() async {
    try {
      final response = await _dio.get('/health');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        return RagHealthResponse.fromJson(data as Map<String, dynamic>);
      }

      throw RagApiException(
        'Health check failed',
        statusCode: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      throw RagApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        response: e.response?.data,
      );
    }
  }

  /// Send query to RAG server
  Future<RagQueryResponse> query(RagQueryRequest request) async {
    try {
      final response = await _dio.post(
        '/api/query',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        return RagQueryResponse.fromJson(data as Map<String, dynamic>);
      }

      throw RagApiException(
        'Query failed',
        statusCode: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      throw RagApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        response: e.response?.data,
      );
    }
  }

  /// Rebuild the RAG index from PDF
  Future<RagRebuildResponse> rebuildIndex() async {
    try {
      final response = await _dio.post('/api/rebuild');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        return RagRebuildResponse.fromJson(data as Map<String, dynamic>);
      }

      throw RagApiException(
        'Rebuild failed',
        statusCode: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      throw RagApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        response: e.response?.data,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
