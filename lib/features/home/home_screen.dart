import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../../utils/routes.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [gradient1, gradient2]),
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/im_icon.svg',
                      width: 307,
                      height: 97,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50,right: 30),
                      child: InkWell(
                          onTap: () => Get.toNamed(settingsRoute),
                          child: SvgPicture.asset('assets/icons/ic_settings.svg')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ic_home_image.png', width: 300),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: _controller.checkSubscription,
                    child: SizedBox(
                      height: 50,
                      width: 250,
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_button.svg',
                            height: 50,
                            width: 250,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Scan Invoice',
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
