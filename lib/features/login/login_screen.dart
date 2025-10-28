import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/widgets/icon_text_field.dart';
import 'package:invoice/features/login/login_controller.dart';

import '../../utils/colors.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [gradient1, gradient2],begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                            'Login to continue',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF02AC5B),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            IconTextField(
                              hint: 'Username',
                              controller: _controller.userNameController,
                              whiteBackground: true,
                            ),
                            const SizedBox(height: 10,),
                            IconTextField(
                              hint: 'Password',
                              controller: _controller.passwordController,
                              whiteBackground: true,
                            ),
                            const SizedBox(height: 10,),
                            IconTextField(
                              hint: 'Company Code',
                              controller: _controller.companyCodeController,
                              whiteBackground: true,
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () => _controller.onLoginClicked(),
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
                                        'Login',
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
                      Obx(() => Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Text(
                          'v ${_controller.version.value}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFb4b4b4),
                          ),
                        ),
                      ),)
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
