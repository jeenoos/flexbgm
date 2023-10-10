import 'package:flextv_bgm_player/controllers/signup_controller.dart';
import 'package:flextv_bgm_player/widget/app_logo.dart';
import 'package:flextv_bgm_player/widget/button.dart';
import 'package:flextv_bgm_player/widget/text_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends GetView<SignupController> {
  const SignUp({super.key});
  static const route = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: AppLogo(),
              ),
              //이메일 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextInput(
                  hintText: '이메일',
                  controller: controller.emailController,
                ),
              ),
              //비밀번호 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextInput(
                  hintText: '비밀번호',
                  controller: controller.pwController,
                ),
              ),
              //비밀번호 확인 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextInput(
                  hintText: '비밀번호 확인',
                  controller: controller.pwConfirmController,
                ),
              ),
              //닉네임 입력 필드
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextInput(
                  hintText: '닉네임',
                  controller: controller.userNameController,
                ),
              ),
              //입력 형식 오류 메세지
              Obx(
                () => Text(
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                  controller.errorMsg.value,
                ),
              ),
              //회원가입 버튼
              Button(
                margin: const EdgeInsets.all(8.0),
                text: '회원가입',
                onPressed: () async {
                  if (await controller.signup()) {
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
