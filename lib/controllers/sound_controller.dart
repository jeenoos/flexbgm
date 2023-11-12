import 'dart:ffi';

import 'package:audio_session/audio_session.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/audio/audio_ui.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SoundController extends GetxController with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final RxBool isEdit = RxBool(false);
  final RxnDouble drag = RxnDouble(null);
  final RxDouble payload = RxDouble(0.0);
  final Rxn<RangeValues> range = Rxn(null);
  TextEditingController urlController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  AudioPlayer get player => _player;

  @override
  void onInit() async {
    super.onInit();
    _init();
  }

  void setUri(String path) async {
    Uri uri = Uri.parse(path);
    if (uri.isScheme('https') || uri.isScheme('http')) {
      _player.setUrl(path);
    } else {
      _player.setFilePath(path);
    }
    Duration? res = await _player.load();

    if (res != null) {
      _player.seek(Duration(milliseconds: range.value!.start.toInt()));
      payload.value = res.inMilliseconds.toDouble();
    }
  }

  void setSound(Sound sound) async {
    range.value = sound.source.range;
    setUri(sound.source.uri);
  }

  void reset() {
    pathController.text = '';
    urlController.text = '';
    isEdit.value = false;
    drag.value = null;
    range.value = null;
    payload.value = 0;
    _player.stop();
  }

  void play() {
    if (range.value == null) {
      _player.play();
    } else {
      _player
          .seek(Duration(milliseconds: range.value!.start.toInt()))
          .then((value) => _player.play());
    }
  }

  void stop() {
    _player.stop();
    _player.seek(Duration(
        milliseconds: range.value == null ? 0 : range.value!.start.toInt()));
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {
      // debugPrint('stream => ${event.updatePosition}');
    }, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });

    // try {
    //   // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
    //   await _player.setAudioSource(AudioSource.uri(Uri.parse(
    //       "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")));
    // } catch (e) {
    //   debugPrint("Error loading audio source: $e");
    // }
  }

  @override
  void dispose() {
    super.dispose();
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  Stream<PositionData> get stream {
    return CombineLatestStream.combine3<Duration, Duration, Duration?,
            PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
  }
}
