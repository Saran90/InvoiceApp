import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:invoice/api/api.dart';
import 'package:invoice/main.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:invoice/utils/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/error_response.dart';
import '../../data/error/failures.dart';
import '../../utils/messages.dart';

class ConfigController extends GetxController {
  final baseUrlController = TextEditingController();
  RxBool isLoading = false.obs;
  RxString version = RxString('');

  @override
  void onInit() {
    super.onInit();
    PackageInfo.fromPlatform().then((value) {
      version.value = value.version;
    });
  }

  Future<void> onSaveClicked() async {
    var result = await Api(baseUrl: '').urlValid(url: baseUrlController.text);
    result.fold(
      (l) {
        if (l is APIFailure) {
          ErrorResponse? errorResponse = l.error;
          Get.context!.showMessage(errorResponse?.message ?? apiFailureMessage);
        } else if (l is ServerFailure) {
          Get.context!.showMessage(l.message ?? serverFailureMessage);
        } else if (l is NetworkFailure) {
          Get.context!.showMessage(networkFailureMessage);
        } else {
          Get.context!.showMessage(unknownFailureMessage);
        }
        isLoading.value = false;
      },
      (r) {
        if (r?.status == 1) {
          appStorage.setBaseUrl(url: baseUrlController.text);
          Get.offAndToNamed(loginRoute);
        } else {
          Get.context!.showMessage(r?.statusMessage ?? 'Invalid Url');
        }
      },
    );
  }
}
