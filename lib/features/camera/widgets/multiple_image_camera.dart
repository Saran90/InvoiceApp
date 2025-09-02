import 'package:flutter/material.dart';
import 'package:invoice/features/camera/widgets/camera_file_widget.dart';

class MultipleImageCamera {
  static Future<List<MediaModel>> capture({
    required BuildContext context,
    Widget? customDoneButton,
  }) async {
    List<MediaModel> images = [];
    try {
      images = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (BuildContext context) =>
                  CameraFileWidget(customButton: customDoneButton),
        ),
      );
      // ignore: empty_catches
    } catch (e) {}
    return images;
  }
}
