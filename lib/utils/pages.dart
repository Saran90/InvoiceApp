import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:invoice/features/camera/multi_camera_binding.dart';
import 'package:invoice/features/camera/muti_camera_screen.dart';
import 'package:invoice/features/config/config_binding.dart';
import 'package:invoice/features/config/config_screen.dart';
import 'package:invoice/features/history/history_binding.dart';
import 'package:invoice/features/history/history_screen.dart';
import 'package:invoice/features/home/home_binding.dart';
import 'package:invoice/features/home/home_screen.dart';
import 'package:invoice/features/image_view/image_view_binding.dart';
import 'package:invoice/features/image_view/image_view_screen.dart';
import 'package:invoice/features/login/login_binding.dart';
import 'package:invoice/features/login/login_screen.dart';
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
    // binding: MultiCameraBinding(),
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
  GetPage(
    name: imageViewRoute,
    binding: ImageViewBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: ImageViewScreen(),
        ),
  ),
  GetPage(
    name: historyRoute,
    // binding: HistoryBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: HistoryScreen(),
        ),
  ),
  GetPage(
    name: configRoute,
    binding: ConfigBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: ConfigScreen(),
        ),
  ),
  GetPage(
    name: loginRoute,
    binding: LoginBinding(),
    page:
        () => Directionality(
          textDirection: TextDirection.ltr,
          child: LoginScreen(),
        ),
  ),
];
