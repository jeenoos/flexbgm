import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/audio/audio_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'audio_ui.dart';

class AudioPlayer extends GetView<SoundController> with WidgetsBindingObserver {
  AudioPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Obx(() => Container(
                          height: 60,
                          width: 160.0,
                          color: controller.isEdit.value
                              ? Colors.redAccent
                              : Colors.amber,
                          child: AudioControls(player: controller.player),
                        )),
                    Expanded(
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
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black87,
              shadowColor: Colors.grey,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              minimumSize: const Size(100, 65), //////// HERE
            ),
            onPressed: () => controller.isEdit.value = !controller.isEdit.value,
            child: Obx(() {
              return controller.isEdit.value
                  ? const Text('편집완료')
                  : const Text('구간편집');
            }),
          ),
        )
      ],
    );
  }
}
