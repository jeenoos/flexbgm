import 'dart:math';

import 'package:flextv_bgm_player/controllers/sound_controller.dart';
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
        // Opens volume slider dialog

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

class RepeatButton extends GetView<SoundController> {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Icon icon;
    switch (controller.repeatState.value) {
      case RepeatState.off:
        icon = const Icon(Icons.repeat, color: Colors.grey);
        break;
      case RepeatState.repeatSong:
        icon = const Icon(Icons.repeat_one);
        break;
      case RepeatState.repeatPlaylist:
        icon = const Icon(Icons.repeat);
        break;
    }
    return IconButton(
      icon: icon,
      onPressed: controller.repeat,
    );
  }
}

class PreviousSongButton extends GetView<SoundController> {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: controller.prev,
    );
  }
}

class NextSongButton extends GetView<SoundController> {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: controller.next,
    );
  }
}

class PlayButton extends GetView<SoundController> {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    switch (controller.playState.value) {
      case PlayState.loading:
        return Container(
            margin: const EdgeInsets.all(8.0),
            width: 32.0,
            height: 32.0,
            child: const CircularProgressIndicator());
      case PlayState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 32.0,
          onPressed: controller.play,
        );
      case PlayState.playing:
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 32.0,
          onPressed: controller.pause,
        );
    }
  }
}

class ShuffleButton extends GetView<SoundController> {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: (controller.isShuffle)
          ? const Icon(Icons.shuffle)
          : const Icon(Icons.shuffle, color: Colors.grey),
      onPressed: controller.shuffle,
    );
  }
}

class CurrentSongTitle extends GetView<SoundController> {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(controller.title, style: const TextStyle(fontSize: 40)),
    );
  }
}

class Playlist extends GetView<SoundController> {
  const Playlist({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: controller.titles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(controller.titles[index]),
          );
        });
  }
}

// class AudioProgressBar extends StatelessWidget {
//   const AudioProgressBar({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return ProgressBar(
//       progress: value.current,
//       buffered: value.buffered,
//       total: value.total,
//       onSeek: _pageManager.seek,
//     );
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

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  late SliderThemeData _sliderThemeData;
  SoundController controller = Get.find<SoundController>();
  String? changed;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    double start = controller.range.value!.start;
    double end = controller.range.value!.end;
    double buffer = widget.bufferedPosition.inMilliseconds.toDouble();
    double position = widget.position.inMilliseconds.toDouble();
    double duration = widget.duration.inMilliseconds.toDouble();
    if (position > (controller.isEdit.value ? end : duration)) {
      controller.pause();
    }
    // debugPrint('start: ${start}');
    // debugPrint('end: ${end}');
    // debugPrint('position: ${position}');
    // debugPrint('duration: ${duration}');
    return Stack(
      children: <Widget>[
        // SliderTheme(
        //   data: _sliderThemeData.copyWith(
        //     thumbShape: HiddenThumbComponentShape(),
        //     activeTrackColor: Colors.transparent,
        //     inactiveTrackColor: Colors.transparent,
        //   ),
        //   child: ExcludeSemantics(
        //     child: Slider(
        //       min: 0.0,
        //       max: duration,
        //       value: min(buffer, duration),
        //       onChanged: (value) {},
        //     ),
        //   ),
        // ),
        Visibility(
          visible: duration > 0,
          child: IgnorePointer(
            ignoring: controller.isEdit.value,
            child: FlutterSlider(
              min: 0,
              max: duration,
              values: [min(controller.drag.value ?? position, duration)],
              onDragging: (handlerIndex, lowerValue, upperValue) {
                controller.drag.value = lowerValue;
              },
              onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                controller.seek(lowerValue);
                controller.drag.value = null;
              },
              handlerWidth: 18,
              handlerHeight: 18,
              handler: Handler(
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
                        text: Duration(milliseconds: duration.toInt()).toMMSS(),
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
            handler: Handler(icon: Icons.chevron_right),
            rightHandler: Handler(icon: Icons.chevron_left),
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
  }

  // Duration get _remaining => widget.duration - widget.position;

  Handler({IconData? icon, Color color = Colors.white}) {
    return FlutterSliderHandler(
      decoration: const BoxDecoration(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0.05,
                blurRadius: 5,
                offset: const Offset(0, 1))
          ],
        ),
        child: Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(
            icon,
            color: Colors.grey,
            size: 18,
          ),
        ),
      ),
    );
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
