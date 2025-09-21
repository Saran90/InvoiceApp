import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../../utils/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    gradient1,
                    gradient2,
                  ])
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/im_icon.svg',
                  width: 307,
                  height: 97,
                ),
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
                    onTap: () {
                      Get.toNamed(multiCameraRoute);
                    },
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
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
