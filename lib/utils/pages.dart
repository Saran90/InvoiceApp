import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:invoice/features/camera/multi_camera_binding.dart';
import 'package:invoice/features/camera/muti_camera_screen.dart';
import 'package:invoice/features/home/home_binding.dart';
import 'package:invoice/features/home/home_screen.dart';
import 'package:invoice/utils/routes.dart';

import '../features/invoice/invoice_binding.dart';
import '../features/invoice/invoice_screen.dart';
import '../features/splash/splash_screen.dart';

final routes = [
  GetPage(
    name: '/',
    page:
        () => const Directionality(
          textDirection: TextDirection.ltr,
          child: SplashScreen(),
        ),
  ),
  GetPage(
    name: invoiceRoute,
    binding: InvoiceBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: InvoiceScreen(),
        ),
  ),
  GetPage(
    name: multiCameraRoute,
    binding: MultiCameraBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: MultiCameraScreen(),
        ),
  ),
  GetPage(
    name: homeRoute,
    binding: HomeBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: HomeScreen(),
        ),
  ),
];
