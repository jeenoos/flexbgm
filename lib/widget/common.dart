import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:just_audio/just_audio.dart';

enum PlayState { loading, buffering, ready, paused, playing, stoped }

// Feed your own stream of bytes into the player
class BgmSource extends StreamAudioSource {
  final List<int> bytes;
  BgmSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mp3',
    );
  }
}

SliderHandler({IconData? icon, Color color = Colors.white, bool hide = false}) {
  return FlutterSliderHandler(
    decoration: const BoxDecoration(),
    child: Visibility(
      visible: !hide,
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
    ),
  );
}
