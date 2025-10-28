import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:invoice/main.dart';
import 'package:invoice/utils/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  RxString name = ''.obs;
  RxString baseUrl = ''.obs;
  RxString version = RxString('');

  @override
  void onInit() {
    name.value = appStorage.getUsername() ?? '';
    baseUrl.value = appStorage.getBaseUrl() ?? '';
    PackageInfo.fromPlatform().then((value) {
      version.value = value.version;
    });
    super.onInit();
  }

  void onLogoutClicked() {
    appStorage.clear();
    Get.offAllNamed(configRoute);
  }
}
