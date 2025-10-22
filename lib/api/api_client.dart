import 'package:get/get.dart';

import '../main.dart';
import '../utils/routes.dart';

class ApiClient extends GetConnect implements GetxService {
  final String baseUrl;
  final bool isAuthenticated;

  ApiClient({required this.baseUrl, this.isAuthenticated = false}) {
    baseUrl = baseUrl;
  }

  @override
  void onInit() {
    httpClient.addRequestModifier<void>((request) {
      String? accessToken = appStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers.addIf(
          isAuthenticated,
          'Authorization',
          'Bearer $accessToken',
        );
      }
      return request;
    });
    httpClient.addResponseModifier((request, response) {
      print('API: ${request.method} | ${request.url}');
      if (!response.isOk) {
        // Log error or show a dialog/snackbar
        print('Error: ${response.statusCode} - ${response.bodyString}');

        // You can throw a custom exception or return a fallback response
        // throw Exception('API Error: ${response.statusCode}');
      } else {
        print('Success: ${response.statusCode} - ${response.bodyString}');
      }
      if (isAuthenticated && response.statusCode == 401) {
        Get.offAllNamed(configRoute);
      }
      return response;
    });
    super.onInit();
  }
}
