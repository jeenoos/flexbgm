import 'dart:math';
import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// Displays the play/pause button and volume/speed sliders.
class AudioControls extends GetView<SoundController> {
  final AudioPlayer player;
  const AudioControls({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 40.0,
                height: 40.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 40.0,
                onPressed: controller.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
                iconSize: 40.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(
                  Icons.replay,
                  color: Colors.white,
                ),
                iconSize: 40.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
      ],
    );
  }
}

class PlayButton extends GetView<SoundController> {
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

class StopButton extends GetView<SoundController> {
  const StopButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shuffle, color: Colors.white),
      onPressed: controller.stop,
    );
  }
}

// class Playlist extends GetView<SoundController> {
//   const Playlist({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         itemCount: controller.titles.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(controller.titles[index]),
//           );
//         });
//   }
// }

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SeekBar extends GetView<SoundController> {
  const SeekBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double start = controller.range.value.start;
      double end = controller.range.value.end;
      double buffer = controller.buffer.value.toDouble();
      double position = controller.current.value.toDouble();
      double duration = controller.total.value.toDouble();
      return Stack(
        children: <Widget>[
          Visibility(
            visible: duration > 0,
            child: FlutterSlider(
              min: 0,
              max: duration,
              values: [buffer],
              handlerWidth: 20,
              handlerHeight: 20,
              handler: SliderHandler(hide: true),
              trackBar: const FlutterSliderTrackBar(
                activeTrackBar: BoxDecoration(
                  color: Colors.black26,
                ),
                inactiveTrackBar: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: controller.isEdit.value,
            child: Visibility(
              visible: duration > 0,
              child: FlutterSlider(
                min: 0,
                max: duration,
                values: [min(controller.drag.value ?? position, duration)],
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  controller.drag.value = lowerValue;
                },
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  controller.seek(Duration(milliseconds: lowerValue.toInt()));
                  controller.drag.value = null;
                },
                handlerWidth: 20,
                handlerHeight: 20,
                handler: SliderHandler(
                    icon: null,
                    color: controller.isEdit.value ? Colors.red : Colors.white),
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: BoxDecoration(
                    color: controller.isEdit.value
                        ? Colors.transparent
                        : Colors.blue,
                  ),
                  inactiveTrackBar: BoxDecoration(
                    color: controller.isEdit.value ? Colors.transparent : null,
                  ),
                ),
                tooltip: FlutterSliderTooltip(
                  disabled: controller.isEdit.value,
                  alwaysShowTooltip: true,
                  textStyle: const TextStyle(
                    // fontSize: 20,
                    color: Colors.black,
                  ),
                  positionOffset: FlutterSliderTooltipPositionOffset(top: 5),
                  boxStyle: const FlutterSliderTooltipBox(),
                  custom: (value) {
                    return RichText(
                      maxLines: 1,
                      text: TextSpan(
                        text: Duration(milliseconds: value.toInt()).toMMSS(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                  format: (String value) {
                    return Duration(milliseconds: double.parse(value).toInt())
                        .toMMSS();
                  },
                ),
                hatchMark: FlutterSliderHatchMark(
                  labelsDistanceFromTrackBar: 40,
                  // means 50 lines, from 0 to 100 percent
                  labels: [
                    FlutterSliderHatchMarkLabel(
                      percent: 1,
                      label: const Text(
                        '0:00:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlutterSliderHatchMarkLabel(
                      percent: 100.0,
                      label: RichText(
                        maxLines: 1,
                        text: TextSpan(
                          text:
                              Duration(milliseconds: duration.toInt()).toMMSS(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: controller.isEdit.value && duration > 0,
            child: FlutterSlider(
              rangeSlider: true,
              min: 0,
              max: max(end, duration),
              values: [start, end],
              onDragging: (handlerIndex, lowerValue, upperValue) {
                controller.range.value = RangeValues(lowerValue, upperValue);
              },
              onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                controller.seekAndPlay(
                    handlerIndex == 0 ? lowerValue : upperValue - 3000);
              },
              handlerWidth: 18,
              handlerHeight: 18,
              handlerAnimation: const FlutterSliderHandlerAnimation(
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.bounceIn,
                  duration: Duration(milliseconds: 0),
                  scale: 1),
              handler: SliderHandler(icon: Icons.chevron_right),
              rightHandler: SliderHandler(icon: Icons.chevron_left),
              trackBar: const FlutterSliderTrackBar(
                activeTrackBar: BoxDecoration(
                  color: Colors.redAccent,
                ),
              ),
              tooltip: FlutterSliderTooltip(
                alwaysShowTooltip: true,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                positionOffset: FlutterSliderTooltipPositionOffset(top: 5),
                boxStyle: const FlutterSliderTooltipBox(),
                format: (String value) {
                  return Duration(milliseconds: double.parse(value).toInt())
                      .toMMSS();
                },
                custom: (value) {
                  return RichText(
                    maxLines: 1,
                    text: TextSpan(
                      text: Duration(milliseconds: value.toInt()).toMMSS(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

extension on Duration {
  String toMMSS() {
    var microseconds = inMicroseconds;
    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    // var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";

    var milliseconds = microseconds ~/ Duration.microsecondsPerMillisecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerMillisecond);
    milliseconds = (milliseconds * 0.1).floor();
    var milliPadding = milliseconds < 10 ? "0" : "";
    return "$minutes:"
        "$secondsPadding$seconds:"
        "$milliPadding${(milliseconds)}";
  }
}
