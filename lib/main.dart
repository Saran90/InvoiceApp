import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:invoice/api/api.dart';
import 'package:invoice/features/invoice/models/invoice.dart';
import 'package:invoice/utils/colors.dart';
import 'package:invoice/utils/pages.dart';
import 'package:get/get.dart';

import 'api/endpoints.dart';
import 'data/app_storage.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

AppStorage appStorage = AppStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Invoice',
      getPages: routes,
      builder: (_, child) => TextScaleFactorClamper(
        minTextScaleFactor: 1,
        maxTextScaleFactor: 1,
        child: child!,
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: gradient1),
        useMaterial3: true,
      ),
    );
  }
}
class TextScaleFactorClamper extends StatelessWidget {
  /// {@macro text_scale_factor_clamper}
  const TextScaleFactorClamper({
    super.key,
    required this.child,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  })  : assert(
  minTextScaleFactor == null ||
      maxTextScaleFactor == null ||
      minTextScaleFactor <= maxTextScaleFactor,
  'minTextScaleFactor must be less than maxTextScaleFactor',
  ),
        assert(
        maxTextScaleFactor == null ||
            minTextScaleFactor == null ||
            maxTextScaleFactor >= minTextScaleFactor,
        'maxTextScaleFactor must be greater than minTextScaleFactor',
        );

  /// Child widget.
  final Widget child;

  /// Min text scale factor.
  final double? minTextScaleFactor;

  /// Max text scale factor.
  final double? maxTextScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final constrainedTextScaleFactor = mediaQueryData.textScaler.clamp(
      minScaleFactor: minTextScaleFactor ?? 1,
      maxScaleFactor: maxTextScaleFactor ?? 1.3,
    );

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: constrainedTextScaleFactor,
      ),
      child: child,
    );
  }
}
