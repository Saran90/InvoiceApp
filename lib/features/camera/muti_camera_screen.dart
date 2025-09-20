import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:invoice/features/camera/widgets/multi_camera_preview.dart';
import 'package:invoice/utils/routes.dart';

import 'models/media_model.dart';
import 'multi_camera_controller.dart';

class MultiCameraScreen extends StatefulWidget {
  MultiCameraScreen({super.key});

  @override
  State<MultiCameraScreen> createState() => _MultiCameraScreenState();
}

class _MultiCameraScreenState extends State<MultiCameraScreen> {
  final _controller = Get.put<MultiCameraController>(MultiCameraController());

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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      extendBody: false,
      body: _buildCameraPreview(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () =>
                  (_controller.cameraController.value != null)
                      ? Expanded(child: Center(child: MultiCameraPreview()))
                      : Expanded(child: Container()),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _controller.imageFiles.length,
                itemBuilder: ((context, index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomLeft,
                        // ignore: unnecessary_null_comparison
                        child: ScaleTransition(
                          scale: _controller.scaleAnimation.value!,
                          child: GestureDetector(
                            onTap: () {},
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_controller.imageFiles[index].path),
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
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      child: Center(
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  );
                }),
                scrollDirection: Axis.horizontal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: InkWell(
                          onTap: _controller.onCameraSwitch,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/ic_camera.svg',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          _controller.currIndex.value =
                              _controller.currIndex.value == 0 ? 1 : 0;
                          _controller.takePicture();
                        },
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/ic_shutter.svg',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _controller.imageFiles.isNotEmpty
                        ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                for (
                                  int i = 0;
                                  i < _controller.imageFiles.length;
                                  i++
                                ) {
                                  File file = File(
                                    _controller.imageFiles[i].path,
                                  );
                                  _controller.imageList.add(
                                    MediaModel.blob(
                                      file,
                                      "",
                                      file.readAsBytesSync(),
                                    ),
                                  );
                                }
                                var list = _controller.imageList;
                                if (_controller.isFromInvoice.value) {
                                  Get.back(result: list);
                                } else {
                                  Get.offAndToNamed(
                                    invoiceRoute,
                                    arguments: list,
                                  );
                                }
                              },
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_next.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MultiCameraController>();
    super.dispose();
  }
}
