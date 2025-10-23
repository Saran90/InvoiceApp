import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:invoice/api/api.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:invoice/utils/routes.dart';

import '../../api/error_response.dart';
import '../../data/error/failures.dart';
import '../../main.dart';
import '../../utils/messages.dart';

class LoginController extends GetxController {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final companyCodeController = TextEditingController();

  final Api api = Api(baseUrl: appStorage.getBaseUrl() ?? '');
  RxBool isLoading = RxBool(false);

  Future<void> onLoginClicked() async {
    if (_validateFields()) {
      isLoading.value = true;
      var result = await api.login(
        username: userNameController.text,
        password: passwordController.text,
        companyCode: companyCodeController.text,
      );
      result.fold(
        (l) {
          if (l is APIFailure) {
            ErrorResponse? errorResponse = l.error;
            Get.context!.showMessage(
              errorResponse?.message ?? apiFailureMessage,
            );
          } else if (l is ServerFailure) {
            Get.context!.showMessage(l.message ?? serverFailureMessage);
          } else if (l is NetworkFailure) {
            Get.context!.showMessage(networkFailureMessage);
          } else {
            Get.context!.showMessage(unknownFailureMessage);
          }
          isLoading.value = false;
        },
        (r) async {
          if (r?.status == 1) {
            await appStorage.setAccessToken(token: r?.accessToken ?? '');
            await appStorage.setLoginStatus(status: true);
            await appStorage.setS3Folder(folder: r?.s3FolderName ?? '');
            await appStorage.setUserId(userId: r?.userID?.toInt() ?? 0);
            isLoading.value = false;
            Get.offAndToNamed(homeRoute);
          } else {
            isLoading.value = false;
            Get.context!.showMessage(r?.statusMessage ?? 'Login Failed');
          }
        },
      );
    }
  }

  bool _validateFields() {
    if (userNameController.text.isEmpty) {
      Get.context!.showMessage(enterUsernameMessage);
      return false;
    } else if (passwordController.text.isEmpty) {
      Get.context!.showMessage(enterPasswordMessage);
      return false;
    } else if (companyCodeController.text.isEmpty) {
      Get.context!.showMessage(enterCompanyCodeMessage);
      return false;
    } else {
      return true;
    }
  }
}
