// ignore: file_names
import 'dart:math';

import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/app_logo.dart';
import 'package:flextv_bgm_player/widget/audio/audio_controls.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_controls.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';

class Home extends GetView<SoundController> {
  const Home({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Obx(() {
            double position = controller.current.value.toDouble();
            double duration = controller.total.value.toDouble();
            double start = controller.range.value.start.toDouble();

            return Container(
              color: Colors.black26,
              height: 10,
              child: position >= start && start <= duration ? null : null,
            );
          }),
          const Expanded(child: BgmList()),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  SoundController controller = Get.find<SoundController>();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 160,
          child: AppBar(
            toolbarHeight: 60,
            centerTitle: true,
            automaticallyImplyLeading: true,
            backgroundColor: Colors.black87,
            title: const AppLogo(),
          ),
        ),
        Expanded(
            child: Container(
          height: 70,
          color: Colors.black87,
          child: const CurrentSongTitle(),
        )),
        Container(
          height: 70,
          color: Colors.black87,
          child: const BgmControls(),
        )
      ],
    );
  }
}
