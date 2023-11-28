// ignore: file_names
import 'package:flextv_bgm_player/controllers/bgm_controller.dart';
import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/app_logo.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_controls.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_list.dart';
import 'package:flextv_bgm_player/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';

class Home extends GetView<BgmController> {
  const Home({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const Divider(
            color: Colors.black87,
            thickness: 1.0,
            height: 1,
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                height: 50,
                color: const Color.fromARGB(255, 24, 24, 24),
                child: const CurrentSongTitle(),
              )),
              Container(
                height: 50,
                color: const Color.fromARGB(255, 24, 24, 24),
                child: const BgmControls(),
              ),
            ],
          ),
          Obx(
            () {
              double position = controller.current.value.toDouble();
              double duration = controller.total.value.toDouble();
              return Container(
                color: Colors.black,
                height: position > 0 ? 4 : 0,
                child: Visibility(
                  visible: position > 0,
                  child: FlutterSlider(
                    min: 0.0,
                    max: duration,
                    values: [position],
                    handlerHeight: 0,
                    handlerWidth: 0,
                    handler: SliderHandler(hide: true),
                    trackBar: const FlutterSliderTrackBar(
                      activeTrackBarHeight: 10,
                      inactiveTrackBarHeight: 10,
                      activeTrackBar: BoxDecoration(color: Colors.redAccent),
                    ),
                  ),
                ),
              );
            },
          ),
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
    return AppBar(
      toolbarHeight: 60,
      centerTitle: true,
      automaticallyImplyLeading: true,
      backgroundColor: Colors.black,
      title: const AppLogo(),
    );
  }
}
