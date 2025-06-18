import 'dart:io';


import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/auth/auth_api.service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

///
/// A singleton service class to handle communications w/ API's
///
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();

  factory FileUploadService() {
    return _instance;
  }

  FileUploadService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

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

  static const String kBaseUrl = "https://api.aroundu.in/";
  late final Dio dio;
  final AuthService authService = AuthService();

  Future<Response> upload(
      String url, File file, Map<String, dynamic> data) async {
    var formData = FormData.fromMap(
        {'file': await MultipartFile.fromFile(file.path), ...data});
    // Dio dio = Dio();
    final response = await dio.post(
      kBaseUrl + url,
      data: formData,
      options: Options(
        headers: await authService.getAuthHeaders(),
      ),
    );
    return response;
  }
}
