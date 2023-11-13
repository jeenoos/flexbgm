import 'dart:math';

import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flutter/material.dart';
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
    debugPrint('duration: ${duration}');
    // debugPrint('start: ${start}');
    // debugPrint('end: ${end}');
    // debugPrint('position: ${position}');
    // debugPrint('duration: ${duration}');

    return Stack(
      children: <Widget>[
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.grey.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: duration,
              value: min(buffer, duration),
              onChanged: (value) {},
            ),
          ),
        ),
        Obx(() {
          return Stack(
            children: [
              Visibility(
                visible: controller.isEdit.value,
                child: SliderTheme(
                  data: _sliderThemeData.copyWith(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.redAccent,
                    rangeThumbShape: CustomRangeSliderThumbShape(),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: RangeSlider(
                    values: RangeValues(
                      start,
                      end,
                    ),
                    min: 0.0,
                    max: max(end, duration),
                    labels: RangeLabels(
                      Duration(
                              milliseconds:
                                  controller.range.value?.start.toInt() ??
                                      position.toInt())
                          .toMMSS(),
                      Duration(
                              milliseconds:
                                  controller.range.value?.end.toInt() ??
                                      duration.toInt())
                          .toMMSS(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        if (controller.range.value?.start != values.start) {
                          changed = 'start';
                        }
                        if (controller.range.value?.end != values.end) {
                          changed = 'end';
                        }
                      });
                      controller.range.value = values;
                    },
                    onChangeEnd: (values) {
                      if (widget.onChangeEnd != null) {
                        if (changed == 'start') {
                          widget.onChangeEnd!(values.start.milliseconds);
                        }
                        if (changed == 'end') {
                          widget.onChangeEnd!(values.end.milliseconds);
                        }
                      }
                    },
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: controller.isEdit.value,
                child: SliderTheme(
                    data: _sliderThemeData.copyWith(
                      activeTrackColor: controller.isEdit.value
                          ? Colors.transparent
                          : Colors.amber,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.amber,
                      thumbShape: CustomSliderThumbShape(duration: duration),
                      showValueIndicator: ShowValueIndicator.onlyForContinuous,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: duration,
                      value: min(controller.drag.value ?? position, duration),
                      onChanged: (value) {
                        controller.drag.value = value;
                      },
                      onChangeEnd: (value) {
                        if (widget.onChangeEnd != null) {
                          widget.onChangeEnd!(value.milliseconds);
                        }
                        controller.drag.value = null;
                      },
                    )),
              ),
            ],
          );
        }),
        Positioned(
          right: 16.0,
          bottom: 5.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("${widget.duration}")
                      ?.group(1) ??
                  '${widget.duration}',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  // Duration get _remaining => widget.duration - widget.position;
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

class CustomSliderThumbShape extends SliderComponentShape {
  CustomSliderThumbShape({required this.duration});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;
  double duration;
  late TextPainter labelTextPainter = TextPainter()
    ..textDirection = TextDirection.ltr;
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
  }) {
    final Canvas canvas = context.canvas;
    final Paint strokePaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 7.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, 7.5, strokePaint);

    labelTextPainter.text = TextSpan(
        text: Duration(milliseconds: (duration * value).toInt()).toMMSS(),
        style: const TextStyle(fontSize: 14, color: Colors.black));
    labelTextPainter.layout();
    labelTextPainter.paint(
        canvas,
        center.translate(
            -labelTextPainter.width / 2, labelTextPainter.height / 2));
  }
}

class CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  double? start;
  double? end;
  late TextPainter labelTextPainter = TextPainter()
    ..textDirection = TextDirection.ltr;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;
    final Paint strokePaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 7.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, 7.5, strokePaint);
    if (thumb == null) {
      return;
    }
    final value = thumb == Thumb.start ? start : end;
    labelTextPainter.text = TextSpan(
        text: value?.toStringAsFixed(2),
        style: const TextStyle(fontSize: 14, color: Colors.black));
    labelTextPainter.layout();
    labelTextPainter.paint(
        canvas,
        center.translate(
            -labelTextPainter.width / 2, labelTextPainter.height / 2));
  }
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
    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";

    // var milliseconds = microseconds ~/ Duration.microsecondsPerMillisecond;
    // microseconds = microseconds.remainder(Duration.microsecondsPerMillisecond);
    // var milliPadding = milliseconds < 10 ? "0" : "";

    return "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
    // "$milliPadding${milliseconds.toString().substring(0, 1)}";
  }
}
