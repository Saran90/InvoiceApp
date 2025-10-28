import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/widgets/icon_text_field.dart';

import '../../utils/colors.dart';
import 'config_controller.dart';

class ConfigScreen extends StatelessWidget {
  ConfigScreen({super.key});

  final _controller = Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradient1, gradient2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              height: Get.height*0.4,
              child: Center(
                child: SizedBox(
                  width: 160,
                  height: 198,
                  child: Image.asset(
                    'assets/icons/ic_logo.png',
                    width: 160,
                    height: 198,
                  ),
                ),
              ),
            ),
            Container(
              height: Get.height*0.6,
              color: Colors.white,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Welcome!',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Verify Your Domain to continue',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF02AC5B),
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            IconTextField(
                              hint: 'Domain URL',
                              controller: _controller.baseUrlController,
                              whiteBackground: true,
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () => _controller.onSaveClicked(),
                              child: SizedBox(
                                height: 55,
                                width: Get.width,
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/ic_button.svg',
                                      height: 55,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Verify Domain',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Obx(() => Text(
                        'v ${_controller.version.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFb4b4b4),
                        ),
                      ),),
                    ],
                  ),
                  Obx(() => Visibility(
                      visible: _controller.isLoading.value,
                      child: Center(child: CircularProgressIndicator(
                        color: gradient2,
                      ))),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
