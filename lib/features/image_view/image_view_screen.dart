import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'image_view_controller.dart';

class ImageViewScreen extends StatelessWidget {
  ImageViewScreen({super.key});

  final _controller = Get.find<ImageViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Obx(
              () => Image.file(
                _controller.selectedImage.value!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 48, left: 24),
              child: IconButton(
                onPressed: _controller.onBackClicked,
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
