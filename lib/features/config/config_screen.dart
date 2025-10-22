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
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                'Config Screen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTextField(
                  hint: 'Enter url',
                  controller: _controller.baseUrlController,
                  whiteBackground: true,
                ),
                const SizedBox(height: 40,),
                InkWell(
                  onTap: () => _controller.onSaveClicked(),
                  child: SizedBox(
                    height: 55,
                    width: 250,
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_button_blue.svg',
                          height: 55,
                          width: 250,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Save',
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
