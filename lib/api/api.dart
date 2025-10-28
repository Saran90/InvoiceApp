import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice/api/api_client.dart';
import 'package:invoice/api/models/check_subscription_response.dart';
import 'package:invoice/api/models/url_valid_response.dart';
import 'package:invoice/main.dart';

import '../data/error/failures.dart';
import '../utils/messages.dart';
import 'endpoints.dart';
import 'error_response.dart';
import 'models/login_response.dart';

class Api extends ApiClient {
  Api({required this.baseUrl}) : super(baseUrl: baseUrl);

  final String baseUrl;

  Future<Either<Failure, LoginResponse?>> login({
    required String username,
    required String password,
    required String companyCode,
  }) async {
    String baseUrl = appStorage.getBaseUrl() ?? '';
    print("Base Url: $baseUrl");
    this.baseUrl = baseUrl;
    try {
      var response = await get(
        '$loginUrl?username=$username&password=$password&CompanyCode=$companyCode',
      );
      if (response.isOk) {
        LoginResponse loginResponse = LoginResponse.fromJson(response.body);
        return Right(loginResponse);
      } else if (response.statusCode == 401) {
        return Left(ServerFailure(message: loginFailedMessage));
      } else {
        ErrorResponse? errorResponse = ErrorResponse.fromJson(response.body);
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
    } catch (exception) {
      debugPrint('Login Call: $exception');
      if (exception is DioException) {
        debugPrint('Login Call Exception: ${exception.message}');
        ErrorResponse? errorResponse = ErrorResponse.fromJson(
          exception.response?.data,
        );
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
      return Left(ServerFailure(message: exception.toString()));
    }
  }

  Future<Either<Failure, UrlValidResponse?>> urlValid({
    required String url,
  }) async {
    String baseUrl = url;
    print("Base Url: $baseUrl");
    this.baseUrl = baseUrl;
    try {
      var response = await get('$baseUrl$urlValidUrl');
      if (response.isOk) {
        UrlValidResponse urlValidResponse = UrlValidResponse.fromJson(
          response.body,
        );
        return Right(urlValidResponse);
      } else if (response.statusCode == 401) {
        return Left(ServerFailure(message: loginFailedMessage));
      } else {
        ErrorResponse? errorResponse = ErrorResponse.fromJson(response.body);
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
    } catch (exception) {
      debugPrint('UrlValid Call: $exception');
      if (exception is DioException) {
        debugPrint('UrlValid Call Exception: ${exception.message}');
        ErrorResponse? errorResponse = ErrorResponse.fromJson(
          exception.response?.data,
        );
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
      return Left(ServerFailure(message: 'Invalid url'));
    }
  }

  Future<Either<Failure, CheckSubscriptionResponse?>>
  checkSubscription() async {
    String baseUrl = appStorage.getBaseUrl() ?? '';
    print("Base Url: $baseUrl");
    this.baseUrl = baseUrl;
    isAuthenticated = true;
    try {
      var response = await get(checkSubscriptionUrl,headers: {
        'Authorization': 'Bearer ${appStorage.getAccessToken()}'
      });
      if (response.isOk) {
        CheckSubscriptionResponse checkSubscriptionResponse =
            CheckSubscriptionResponse.fromJson(response.body);
        return Right(checkSubscriptionResponse);
      } else if (response.statusCode == 401) {
        return Left(ServerFailure(message: authFailedMessage));
      } else {
        ErrorResponse? errorResponse = ErrorResponse.fromJson(response.body);
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
    } catch (exception) {
      debugPrint('Check Subscription Call: $exception');
      if (exception is DioException) {
        debugPrint('Check Subscription Exception: ${exception.message}');
        ErrorResponse? errorResponse = ErrorResponse.fromJson(
          exception.response?.data,
        );
        return Left(APIFailure<ErrorResponse>(error: errorResponse));
      }
      return Left(ServerFailure(message: exception.toString()));
    }
  }
}
