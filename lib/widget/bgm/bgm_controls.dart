import 'package:flextv_bgm_player/widget/audio/audio_controls.dart';
import 'package:flutter/material.dart';

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
