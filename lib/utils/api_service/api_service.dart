import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/auth/auth_api.service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class IdToken {
  static Future<String?> get() async {
    final AuthService authService = AuthService();
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    final idToken = await authService.getToken();
    return idToken;
    // }
    // return null;
  }
}

class ApiService<T> {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.arounduBaseUrl, // Set baseUrl globally
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add PrettyDioLogger to intercept and log requests/responses
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // Add token refresh interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // If the error is 401 Unauthorized, try to refresh the token
          if (error.response?.statusCode == 401) {
            // Try to refresh the token
            final authApiService = AuthApiService();
            final refreshed = await authApiService.refreshToken();

            if (refreshed) {
              // If token refresh was successful, retry the original request
              final options = error.requestOptions;
              // Update the Authorization header with the new token
              final authService = AuthService();
              options.headers["Authorization"] =
                  "Bearer ${authService.getToken()}";

              // Create a new request with the updated headers
              final response = await dio.fetch(options);
              return handler.resolve(response);
            }
          }
          // If token refresh failed or error is not 401, continue with the error
          return handler.next(error);
        },
      ),
    );

    // //TODO: Warning : remove this code
    // // WARNING: TESTING CONFIGURATION ONLY
    // // This configuration bypasses security measures and routes traffic through a proxy
    // // Remove before releasing to production
    // // Configure the HTTP client adapter:
    // // Update to the new IOHttpClientAdapter
    // final adapter = IOHttpClientAdapter();

    // // Use createHttpClient instead of onHttpClientCreate
    // adapter.createHttpClient = () {
    //   final client = HttpClient();

    //   // Configure the proxy IP address and port
    //   client.findProxy = (uri) {
    //     // return "PROXY 192.168.169.28:8080"; // Change 8080 to your proxy's port if needed
    //     return "PROXY 10.0.2.2:8080"; // Change 8080 to your proxy's port if needed
    //   };

    //   // Bypass SSL certificate verification (for testing only)
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;

    //   return client;
    // };

    // // Assign the adapter to dio
    // dio.httpClientAdapter = adapter;
  }

  Future<T?> get(String endpoint, T Function(dynamic) serializer) async {
    try {
      var token = await IdToken.get();
      var response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return serializer(response.data);
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<T?> post(String endpoint, dynamic body, T Function(dynamic) serializer,
      {bool useFormUrlEncoded = false}) async {
    try {
      var token = await IdToken.get();
      var options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': useFormUrlEncoded
              ? Headers.formUrlEncodedContentType
              : 'application/json',
        },
      );

      var data =
          useFormUrlEncoded ? body : jsonEncode(body); // Encode accordingly

      var response = await dio.post(
        endpoint,
        data: data,
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("response : $response");
        return serializer(response.data);
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<T?> put(
    String endpoint,
    dynamic body,
    T Function(dynamic) serializer,
  ) async {
    try {
      var token = await IdToken.get();
      var response = await dio.put(
        endpoint,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Set content type to JSON
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return serializer(response.data);
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<T?> patch(
    String endpoint,
    dynamic body,
    T Function(dynamic) serializer,
  ) async {
    try {
      var token = await IdToken.get();
      var response = await dio.patch(
        endpoint,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return serializer(response.data);
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<bool> delete(String endpoint, dynamic body,
      {bool useFormUrlEncoded = false}) async {
    try {
      var token = await IdToken.get();
      var response = await dio.delete(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': useFormUrlEncoded
                ? Headers.formUrlEncodedContentType
                : 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
    } catch (e) {
      log(e.toString());
    }
    return false;
  }
}
