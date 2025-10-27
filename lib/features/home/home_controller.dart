import 'package:get/get.dart';
import 'package:invoice/utils/extensions.dart';

import '../../api/api.dart';
import '../../api/error_response.dart';
import '../../data/error/failures.dart';
import '../../main.dart';
import '../../utils/messages.dart';
import '../../utils/routes.dart';

class HomeController extends GetxController {

  RxBool isLoading = false.obs;
  final Api api = Api(baseUrl: appStorage.getBaseUrl() ?? '');

  Future<void> checkSubscription() async {
    isLoading.value = true;
    var result = await api.checkSubscription();
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
      (r) async {
        if (r?.status == 1) {
          isLoading.value = false;
          Get.toNamed(multiCameraRoute);
        } else {
          isLoading.value = false;
          Get.context!.showMessage(r?.statusMessage ?? 'Please subscribe');
        }
      },
    );
  }
}
