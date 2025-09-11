import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
              color: Color.fromRGBO(3, 108, 173, 1),
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
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/ic_welcome.svg'),
                    Image.asset('assets/images/ic_home_image.png', width: 300),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        Get.offAndToNamed(multiCameraRoute);
                      },
                      child: SizedBox(
                        height: 65,
                        width: 250,
                        child: Stack(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_button.svg',
                              height: 65,
                              width: 250,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Scan Invoice',
                                style: TextStyle(
                                  fontSize: 27,
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
          ),
        ],
      ),
    );
  }
}
