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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: gradient1),
        useMaterial3: true,
      ),
    );
  }
}
