import 'package:flextv_bgm_player/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  var emailController = TextEditingController(); //id 텍스트 필드 컨트롤러
  var pwController = TextEditingController(); //패스워드 텍스트 필트 컨트롤러
  var pwConfirmController = TextEditingController(); //패스워드 확인 텍스트 필트 컨트롤러
  var userNameController = TextEditingController(); //닉네임 텍스트 필트 컨트롤러

  RxString errorMsg = ''.obs;

  //AuthController의 signup()을 사용해 로그인 수행
  Future<bool> signup() async {
    //이메일 형식 체크
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text)) {
      errorMsg('이메일 형식이 잘못되었습니다.');
      return false;
    }
    //비밀번호 글자 수 체크
    if (pwController.text.length < 9) {
      errorMsg('비밀번호는 9자리 이상이어야 합니다.');
      return false;
    }
    //비밀번호와 비밀번호 확인을 체크
    if (pwConfirmController.text != pwController.text) {
      errorMsg('비밀번호와 비밀번호 확인이 다릅니다.');
      return false;
    }
    //username이 null인지 체크
    if (userNameController.text == '') {
      errorMsg('닉네임을 입력하세요.');
      return false;
    }

    await Get.find<AuthController>().signup(
      emailController.text,
      pwController.text,
      pwConfirmController.text,
      userNameController.text,
    );

    return true;
  }
}
