import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import "package:camera/camera.dart";
import 'package:get_storage/get_storage.dart';

import 'models/media_model.dart';

class MultiCameraController extends GetxController
    with GetTickerProviderStateMixin {
  RxDouble zoom = 0.0.obs;
  RxDouble scaleFactor = 1.0.obs;
  RxDouble scale = 1.0.obs;
  RxList<CameraDescription> cameras = RxList<CameraDescription>([]);
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  RxList<XFile> imageFiles = RxList();
  List<MediaModel> imageList = <MediaModel>[];

  RxBool isCameraInitialized = RxBool(false);

  late RxInt currIndex = 0.obs;
  late Animation<double> animation;
  late AnimationController animationController;
  late AnimationController controller;
  Rx<Animation<double>?> scaleAnimation = Rx<Animation<double>?>(null);
  RxBool isFromInvoice = false.obs;

  @override
  void onInit() {
    print('MultiCameraController init');
    imageFiles.value = [];
    imageList = [];
    var from = Get.arguments as Map<String, dynamic>?;
    if(from != null) {
      isFromInvoice.value = (from['from'] == 'invoice');
    }
    _initCamera();
    currIndex.value = 0;
    super.onInit();
  }

  Future<void> _initCamera() async {
    cameras.value = await availableCameras();
    // ignore: unnecessary_null_comparison
    if (cameras != null) {
      cameraController.value = CameraController(
        cameras[0],
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );
      cameraController.value?.initialize().then((value) {
        isCameraInitialized.value = true;
      });
    } else {}
  }

  void addImages(XFile image) {
    imageFiles.add(image);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    animation = Tween<double>(begin: 400, end: 1).animate(
      scaleAnimation.value = CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {});
    animationController.forward();
  }

  void removeImage(int index) {
    imageFiles.removeAt(index);
  }

  Future<void> onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (cameraController.value!.description == cameras[0])
            ? cameras[1]
            : cameras[0];
    if (cameraController.value != null) {
      await cameraController.value!.dispose();
      isCameraInitialized.value = false;
    }
    cameraController.value = CameraController(
      cameraDescription,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    cameraController.value?.addListener(() {
      print('Camera Listener');
      isCameraInitialized.value = cameraController.value!.value.isInitialized;
      update();
    },);
    cameraController.value!.addListener(() {
      update();
      if (cameraController.value!.value.hasError) {}
    });

    try {
      await cameraController.value!.initialize();
      // ignore: empty_catches
    } on CameraException {}
  }

  void takePicture() async {
    if (cameraController.value!.value.isTakingPicture) {
      return null;
    }
    try {
      await cameraController.value!.setFocusMode(FocusMode.locked);
      await cameraController.value!.setExposureMode(ExposureMode.locked);
      final image = await cameraController.value!.takePicture();
      addImages(image);
      HapticFeedback.lightImpact();
      await cameraController.value!.setFocusMode(FocusMode.auto);
      await cameraController.value!.setExposureMode(ExposureMode.auto);
    } on CameraException {
      return null;
    }
  }

  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }

  void disposeAll() {
    print('MultiCameraController dispose');
    if (cameraController.value != null) {
      cameraController.value!.dispose();
      cameraController.value = null;
    } else {
      animationController.dispose();
    }
    imageFiles.clear();
    imageList.clear();
  }
}
