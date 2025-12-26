import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../models/models.dart';

/// Exception for Make.com API errors
class MakeApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  MakeApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'MakeApiException: $message (status: $statusCode)';
}

/// API client for Make.com webhooks (availability and project story)
class MakeApiClient {
  late final Dio _dio;

  MakeApiClient() {
    _dio = Dio(
      BaseOptions(
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
          print('🌐 Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Get availability status from Make.com
  Future<AvailabilityModel> getAvailability() async {
    if (Env.makeAvailabilityUrl.isEmpty) {
      throw MakeApiException('Availability URL not configured');
    }

    try {
      final response = await _dio.post(
        Env.makeAvailabilityUrl,
        data: {'action': 'getAvailability'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        return AvailabilityModel.fromJson(data as Map<String, dynamic>);
      }

      throw MakeApiException(
        'Failed to get availability',
        statusCode: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      throw MakeApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        response: e.response?.data,
      );
    }
  }

  /// Get project story from Make.com
  Future<ProjectStoryResponse> getProjectStory(
      ProjectStoryRequest request) async {
    if (Env.makeProjectStoryUrl.isEmpty) {
      throw MakeApiException('Project Story URL not configured');
    }

    try {
      final response = await _dio.post(
        Env.makeProjectStoryUrl,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        return ProjectStoryResponse.fromJson(data as Map<String, dynamic>);
      }

      throw MakeApiException(
        'Failed to get project story',
        statusCode: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      throw MakeApiException(
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
