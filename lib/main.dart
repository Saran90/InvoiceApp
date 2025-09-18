import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:invoice/features/invoice/models/invoice.dart';
import 'package:invoice/utils/pages.dart';
import 'package:get/get.dart';

import 'features/history/history_controller.dart';

void main() {
  runApp(const MyApp());
  Get.lazyPut(() => HistoryController(),);
  storage.initStorage.then((value) {
    if(value) {
      storage.write('AK', 'AKIARVO6ZMZNSLP5T6D5');
      storage.write('SK', 'o1jtruGqOd/jWb2+wZoavB2aX/vFBNwemKQdU1I+');
    }
  },);
}

GetStorage storage = GetStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Invoice',
      getPages: routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(3, 108, 173, 1)),
        useMaterial3: true,
      ),
    );
  }
}