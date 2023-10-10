import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/audio/controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'common.dart';

class Player extends GetView<SoundController> with WidgetsBindingObserver {
  Player({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        // borderRadius: BorderRadius.circular(6),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Container(
              height: 70,
              width: 160.0,
              color: Colors.amber,
              child: Controls(player: controller.player),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(4),
                ),
                child: StreamBuilder<PositionData>(
                  stream: controller.stream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition:
                          positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: controller.player.seek,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


