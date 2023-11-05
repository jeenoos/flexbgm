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
  final RxnDouble dragValue = RxnDouble(null);
  final Rxn<RangeValues> dragRange = Rxn(null);
  TextEditingController urlController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  AudioPlayer get player => _player;

  @override
  void onInit() async {
    super.onInit();
    _init();
  }

  void setSource(SoundSource source) {
    switch (source.type) {
      case SoundSourceType.file:
        _player.setFilePath(source.uri);
        break;
      case SoundSourceType.url:
      case SoundSourceType.youtube:
        _player.setUrl(source.uri);
        _player.pause();
        break;
      // case SoundSourceType.youtube:
    }
  }

  void reset() {
    pathController.text = '';
    urlController.text = '';
    isEdit.value = false;
    dragValue.value = null;
    dragRange.value = null;
    _player.stop();
  }

  void play() {
    _player.play();
  }

  void stop() {
    _player.stop();
    _player.seek(const Duration(seconds: 0));
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _player.playbackEventStream.listen((event) {
      debugPrint('${event.updatePosition}');
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
