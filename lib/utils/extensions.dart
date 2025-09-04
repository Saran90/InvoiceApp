import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showMessage(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
