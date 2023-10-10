// ignore: file_names
import 'package:flextv_bgm_player/widget/app_logo.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_list.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black87,
        title: const AppLogo(),
      ),
      body: const BgmList(),
    );
  }
}
