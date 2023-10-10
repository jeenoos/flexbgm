import 'package:dio/dio.dart';
import 'package:flextv_bgm_player/constants/app_routes.dart';
import 'package:flextv_bgm_player/service/api/api_service.dart';
import 'package:flextv_bgm_player/utils/Stroge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flextv_bgm_player/model/user.dart';
import 'package:flextv_bgm_player/constants/api_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final Rxn<User> _user = Rxn(); //유저 정보
  final Dio dio = ApiService().instance;
  String? _token; //토큰 값
  Rxn<User> get user => _user; //user 정보 읽기

  //로그인
  signin(String id, String pw, bool isLoginInfoSave) async {
    try {
      var response = await dio.post(
        ApiRoutes.authWithPassword,
        data: {
          'loginId': id,
          'password': pw,
          'loginKeep': false,
          'saveId': false,
          "device": "PCWEB"
        },
      );

      switch (response.statusCode) {
        case 200:
          if (isLoginInfoSave) {
            _token = response.data['token'];
            Storage.set('token', _token);
          }
          var user = User.fromMap(response.data);
          _user(user); //유저 정보 저장
          break;
        case 500:
          throw Exception("서버 오류입니다");
        default:
          debugPrint('e: $response');
      }
    } on DioException catch (e) {
      debugPrint('e: ${e.message}');
    }
  }

  //로그 아웃
  signout() async {
    _user.value = null; //유저 정보 삭제
    Storage.remove('token');
  }

  //회원 가입
  signup(
    String email,
    String password,
    String passwordConfirm,
    String username,
  ) async {
    try {
      await dio.post(
        ApiRoutes.signup,
        data: {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'username': username,
        },
      );
    } on DioException catch (e) {
      debugPrint('e: $e');
    }
  }

  //유저 정보에 따른 페이지 이동
  _handleAuthChanged(User? user) {
    //유저 정보가 있으면 메인페이지로 이동
    if (user != null) {
      Get.offNamed(AppRoutes.home);
      return;
    }
    //유저 정보가 없으면 로그인 페이지로 이동
    Get.offAllNamed(AppRoutes.signin);
    return;
  }

  //로컬에 저장된 토큰을 가져옴
  _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token'); //로컬의 토큰 값을 가져와 저장

    //토큰이 있는 경우
    if (_token != null) {
      try {
        //로그인 요청
        var res = await dio.post(
          ApiRoutes.authRefresh,
          options: Options(headers: {"Authorization": 'Bearer $_token'}),
        );

        if (res.statusCode == 200) {
          var user = User.fromMap(res.data['record']);
          _user(user); //유저 정보 저장
        }
      } on DioException catch (e) {
        debugPrint('e: ${e.message}');
      }
    } else {
      //토큰이 없으면 로그인 페이지로 이동
      Get.offNamed(AppRoutes.signin);
    }
  }

  @override
  void onInit() {
    super.onInit();
    //splash 화면을 2초동안 보여줌
    Future.delayed(const Duration(seconds: 2), () {
      // _autoLogin();
    });
    //유저 정보를 관찰하여 변경된 경우 실행
    ever(_user, _handleAuthChanged);
  }
}
