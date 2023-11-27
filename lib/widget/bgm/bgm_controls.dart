import 'package:flextv_bgm_player/controllers/bgm_controller.dart';
import 'package:flextv_bgm_player/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

/// Displays the play/pause button and volume/speed sliders.
class BgmControls extends StatelessWidget {
  const BgmControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        RepeatButton(),
        PreviousSongButton(),
        PlayButton(),
        NextSongButton(),
        ShuffleButton()
      ],
    );
  }
}


class PlayButton extends GetView<BgmController> {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.playState.value) {
        case PlayState.buffering:
        case PlayState.loading:
          return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator());
        case PlayState.stoped:
        case PlayState.ready:
        case PlayState.paused:
          return IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            iconSize: 32.0,
            onPressed: controller.play,
          );

        case PlayState.playing:
          return IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            iconSize: 32.0,
            onPressed: controller.pause,
          );
      }
    });
  }
}


class PreviousSongButton extends GetView<BgmController> {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Icon(Icons.skip_previous,
            color: controller.isFirst.value
                ? Colors.white.withOpacity(0.3)
                : Colors.white),
        onPressed: controller.prev,
      ),
    );
  }
}

class NextSongButton extends GetView<BgmController> {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Icon(Icons.skip_next,
            color: controller.isLast.value
                ? Colors.white.withOpacity(0.3)
                : Colors.white),
        onPressed: controller.next,
      ),
    );
  }
}

class ShuffleButton extends GetView<BgmController> {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: (controller.isShuffle.value)
            ? const Icon(Icons.shuffle, color: Colors.white)
            : Icon(Icons.shuffle, color: Colors.white.withOpacity(0.3)),
        onPressed: controller.shuffle,
      ),
    );
  }
}

class RepeatButton extends GetView<BgmController> {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Icon icon;
    switch (controller.repeatState.value) {
      case RepeatState.off:
        icon = Icon(Icons.repeat, color: Colors.white.withOpacity(0.3));
        break;
      case RepeatState.repeatSong:
        icon = const Icon(Icons.repeat_one, color: Colors.white);
        break;
      case RepeatState.repeatPlaylist:
        icon = const Icon(Icons.repeat, color: Colors.white);
        break;
    }
    return IconButton(
      icon: icon,
      onPressed: controller.repeat,
    );
  }
}

class CurrentSongTitle extends GetView<BgmController> {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Obx(
        () => Center(
          child: Text(
            controller.title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
