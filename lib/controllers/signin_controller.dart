import 'package:flextv_bgm_player/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SigninController extends GetxController {
  var idController = TextEditingController(); //id 텍스트 필드 컨트롤러
  var pwController = TextEditingController(); //패스워드 텍스트 필트 컨트롤러
  RxBool isLoginInfoSave = false.obs; //로그인 정보 저장 여부

  //AuthController의 login()을 사용해 로그인 수행
  signin() {
    Get.find<AuthController>()
        .signin(idController.text, pwController.text, isLoginInfoSave.value);
  }

  //로그인 정보 저장 체크박스 핸들러
  checkLoginInfoSave(bool? value) {
    if (value != null) {
      isLoginInfoSave(value);
    }
  }
}