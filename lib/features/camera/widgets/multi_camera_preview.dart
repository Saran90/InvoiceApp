// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:invoice/features/camera/multi_camera_controller.dart';

/// A widget showing a live camera preview.
class MultiCameraPreview extends StatelessWidget {
  /// The controller for the camera that the preview is shown for.
  final MultiCameraController _controller = Get.find();

  MultiCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          _controller.cameraController.value != null
              ? _controller.isCameraInitialized.value
                  ? _wrapInRotatedBox(
                    child: CameraPreview(_controller.cameraController.value!),
                  )
                  : Container()
              : Container(color: Colors.green),
    );
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(quarterTurns: _getQuarterTurns(), child: child);
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return _controller.cameraController.value!.value.isRecordingVideo
        ? _controller.cameraController.value!.value.recordingOrientation!
        : (_controller.cameraController.value!.value.previewPauseOrientation ??
            _controller
                .cameraController
                .value!
                .value
                .lockedCaptureOrientation ??
            _controller.cameraController.value!.value.deviceOrientation);
  }
}
