import 'dart:math';

import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
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

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

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
