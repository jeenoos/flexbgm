import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/audio/audio_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayer extends GetView<SoundController> {
  const AudioPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.total.value > 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.zero,
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.zero,
                      ),
                      child: Container(
                        height: 70,
                        color: controller.isEdit.value
                            ? Colors.redAccent
                            : Colors.amber,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showSliderDialog(
                                  context: context,
                                  title: "볼륨",
                                  divisions: 10,
                                  min: 0.0,
                                  max: 1.0,
                                  value: controller.player.volume,
                                  stream: controller.player.volumeStream,
                                  onChanged: controller.player.setVolume,
                                );
                              },
                            ),
                            AudioControls(player: controller.player),
                            StreamBuilder<double>(
                              stream: controller.player.speedStream,
                              builder: (context, snapshot) => IconButton(
                                icon: Text(
                                    "${snapshot.data?.toStringAsFixed(1)}x",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                onPressed: () {
                                  showSliderDialog(
                                    context: context,
                                    title: "재생속도",
                                    divisions: 10,
                                    min: 0.1,
                                    max: 3,
                                    value: controller.player.speed,
                                    stream: controller.player.speedStream,
                                    onChanged: controller.player.setSpeed,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: SeekBar(),
                      ),
                    ),
                  ],
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
                onPressed: () =>
                    controller.isEdit.value = !controller.isEdit.value,
                child: controller.isEdit.value
                    ? const Text('편집완료')
                    : const Text('구간편집'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
