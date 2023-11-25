// ignore: file_names
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
    return Obx(() {
      double position =
          controller.progressState.value.current.inMilliseconds.toDouble();
      double duration =
          controller.progressState.value.total.inMilliseconds.toDouble();

      return Scaffold(
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            Visibility(
              visible: duration > 0.0,
              child: Container(
                color: Colors.black26,
                height: 10,
                child: FlutterSlider(
                  min: 0.0,
                  max: duration,
                  values: [position],
                  handlerHeight: 0,
                  handlerWidth: 0,
                  handler: AudioControls.Handler(hide: true),
                  trackBar: const FlutterSliderTrackBar(
                    activeTrackBarHeight: 10,
                    inactiveTrackBarHeight: 10,
                    activeTrackBar: BoxDecoration(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            const Expanded(child: BgmList()),
          ],
        ),
      );
    });
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
