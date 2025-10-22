import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/widgets/icon_text_field.dart';
import '../../utils/colors.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2],
            begin: Alignment.topLeft,
            stops: [0.5, 1],
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: IconTextField(
                        hint: 'Enter username',
                        controller: _controller.userNameController,
                        whiteBackground: false,
                        textInputType: TextInputType.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconTextField(
                        hint: 'Enter password',
                        controller: _controller.passwordController,
                        whiteBackground: false,
                        isPassword: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconTextField(
                        hint: 'Enter company code',
                        controller: _controller.companyCodeController,
                        whiteBackground: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: InkWell(
                        onTap: () => _controller.onLoginClicked(),
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
                    ),
                  ],
                ),
              ),
              Obx(
                () =>
                    _controller.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
