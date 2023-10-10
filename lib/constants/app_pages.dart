import 'package:flextv_bgm_player/constants/app_routes.dart';
import 'package:flextv_bgm_player/screens/editor.dart';
import 'package:flextv_bgm_player/screens/home.dart';
import 'package:flextv_bgm_player/screens/signin.dart';
import 'package:flextv_bgm_player/screens/signup.dart';
import 'package:get/get.dart';

class AppPages {
  //페이지 라우팅
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const Home()),
    GetPage(name: AppRoutes.editor, page: () => const Editor()),
    GetPage(name: AppRoutes.signin, page: () => const SignIn()),
    GetPage(name: AppRoutes.signup, page: () => const SignUp()),
  ];
}
