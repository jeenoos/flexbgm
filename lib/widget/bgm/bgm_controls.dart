import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/audio/audio_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// Displays the play/pause button and volume/speed sliders.
class BgmControls extends GetView<SoundController> {
  final AudioPlayer player;
  const BgmControls({
    super.key,
    required this.player,
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
