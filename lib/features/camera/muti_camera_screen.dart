import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/features/camera/widgets/multi_camera_preview.dart';

import 'models/media_model.dart';
import 'multi_camera_controller.dart';

class MultiCameraScreen extends StatefulWidget {
  MultiCameraScreen({super.key});

  @override
  State<MultiCameraScreen> createState() => _MultiCameraScreenState();
}

class _MultiCameraScreenState extends State<MultiCameraScreen> {
  final _controller = Get.find<MultiCameraController>();

  @override
  Widget build(BuildContext context) {
    Obx(() {
      if (_controller.cameraController.value != null) {
        if (!_controller.cameraController.value!.value.isInitialized) {
          return Container();
        }
        return SizedBox();
      } else {
        return const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () =>
                _controller.imageFiles.isNotEmpty
                    ? GestureDetector(
                      onTap: () {
                        for (
                          int i = 0;
                          i < _controller.imageFiles.length;
                          i++
                        ) {
                          File file = File(_controller.imageFiles[i].path);
                          _controller.imageList.add(
                            MediaModel.blob(file, "", file.readAsBytesSync()),
                          );
                        }
                        Get.back(result: _controller.imageList);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _animatedButton(customContent: Text('Done')),
                      ),
                    )
                    : const SizedBox(),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey,
      extendBody: false,
      body: _buildCameraPreview(),
    );
  }

  Widget? _animatedButton({Widget? customContent}) {
    return customContent ??
        Container(
          height: 40,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: const Center(
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
  }

  Widget _buildCameraPreview() {
    return Obx(
      () => GestureDetector(
        onScaleStart: (details) {
          _controller.zoom = _controller.scaleFactor;
        },
        onScaleUpdate: (details) {
          _controller.scaleFactor.value = _controller.zoom * details.scale;
          _controller.cameraController.value!.setZoomLevel(
            _controller.scaleFactor.value,
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () =>
                    (_controller.cameraController.value != null)
                        ? Expanded(
                          child: Center(
                            child: MultiCameraPreview(),
                          ),
                        )
                        : Expanded(child: Container()),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _controller.imageFiles.length,
                  itemBuilder: ((context, index) {
                    return Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomLeft,
                          // ignore: unnecessary_null_comparison
                          child:
                          ScaleTransition(
                            scale: _controller.scaleAnimation.value!,
                            child: GestureDetector(
                              onTap: () {},
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(
                                      _controller
                                          .imageFiles[index]
                                          .path,
                                    ),
                                    height: 90,
                                    width: 60,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _controller.removeImage(index);
                                      },
                                      child: Image.network(
                                        "https://logowik.com/content/uploads/images/close1437.jpg",
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  scrollDirection: Axis.horizontal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: IconButton(
                          iconSize: 40,
                          icon: const Icon(
                            Icons.camera_front,
                            color: Colors.white,
                          ),
                          onPressed: _controller.onCameraSwitch,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SafeArea(
                        child: IconButton(
                          iconSize: 80,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (child, anim) => RotationTransition(
                                  turns:
                                      child.key == const ValueKey('icon1')
                                          ? Tween<double>(
                                            begin: 1,
                                            end: 0.75,
                                          ).animate(anim)
                                          : Tween<double>(
                                            begin: 0.75,
                                            end: 1,
                                          ).animate(anim),
                                  child: ScaleTransition(
                                    scale: anim,
                                    child: child,
                                  ),
                                ),
                            child:
                                _controller.currIndex.value == 0
                                    ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      key: const ValueKey("icon1"),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      key: const ValueKey("icon2"),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                          onPressed: () {
                            _controller.currIndex.value =
                                _controller.currIndex.value == 0 ? 1 : 0;
                            _controller.takePicture();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
