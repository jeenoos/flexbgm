import 'dart:ffi';

import 'package:audio_session/audio_session.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/audio/audio_common.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

// import 'package:rxdart/rxdart.dart';
enum PlayState {
  paused,
  playing,
  loading,
}

enum RepeatState { off, repeatSong, repeatPlaylist }

class SoundController extends GetxController with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final RxBool isEdit = RxBool(false);
  final RxnDouble drag = RxnDouble(null);
  final RxDouble payload = RxDouble(0.0);
  final Rxn<RangeValues> range = Rxn(null);
  final Rx<PlayState> playState = Rx(PlayState.loading);
  final Rx<RepeatState> repeatState = Rx(RepeatState.off);
  final Rx<ProgressState> progressState = Rx(const ProgressState(
      buffered: Duration.zero, current: Duration.zero, total: Duration.zero));
  final Rxn<ConcatenatingAudioSource> playlist = Rxn();
  TextEditingController urlController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  AudioPlayer get player => _player;

  bool get isLast => false;

  bool get isShuffle => false;

  String get title => '타이틀';
  List<String> get titles => [];

  @override
  void onInit() async {
    super.onInit();
    _init();
  }

  Future<void> setUri(String path) async {
    Uri uri = Uri.parse(path);
    if (uri.isScheme('https') || uri.isScheme('http')) {
      await _player.setUrl(path);
    } else {
      await _player.setFilePath(path);
    }
    Duration? res = await _player.load();
    if (res != null) {
      double duration = res.inMilliseconds.toDouble();
      range.value = RangeValues(0.0, duration);
      payload.value = duration;
    }
  }

  void setSound(Sound sound) async {
    await setUri(sound.source.uri);
    if (sound.source.range != null) {
      range.value = sound.source.range;
      await _player.setClip(
        start: Duration(milliseconds: range.value!.start.toInt()),
        end: Duration(milliseconds: range.value!.end.toInt()),
      );
    }
  }

  void reset() {
    _player.stop();
    isEdit.value = false;
    pathController.text = '';
    urlController.text = '';
    isEdit.value = false;
    drag.value = null;
    range.value = null;
    payload.value = 0;
  }

  void seekAndPlay(double position) async {
    await _player.seek(Duration(milliseconds: position.toInt()));
    _player.play();
  }

  void play() async {
    isEdit.value ? seekAndPlay(range.value?.start ?? 0) : _player.play();
  }

  void stop() {
    _player.stop();
  }

  void pause() {
    _player.pause();
  }

  void next() {
    debugPrint('next');
  }

  void prev() {}

  void shuffle() {}

  void repeat() {}

  void seek(double position) {
    _player.seek(Duration(milliseconds: position.toInt()));
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    player.playerStateStream.listen((state) {
      // playState.value = state.processingState;
    });

    isEdit.listen((edit) async {
      Duration start = Duration(milliseconds: range.value?.start.toInt() ?? 0);
      Duration end = Duration(
          milliseconds: range.value?.end.toInt() ?? payload.value.toInt());
      edit
          ? await _player.setClip()
          : await _player.setClip(start: start, end: end);
      edit ? await _player.seek(start) : await _player.seek(Duration.zero);
      _player.stop();
    });

    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

  void _listenForChangesInPlayerState() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playState.value = PlayState.loading;
      } else if (!isPlaying) {
        playState.value = PlayState.paused;
      } else if (processingState != ProcessingState.completed) {
        playState.value = PlayState.playing;
      } else {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _player.positionStream.listen((position) {
      final oldState = progressState.value;
      progressState.value = ProgressState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInBufferedPosition() {
    _player.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressState.value;
      progressState.value = ProgressState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    _player.durationStream.listen((totalDuration) {
      final oldState = progressState.value;
      progressState.value = ProgressState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void _listenForChangesInSequenceState() {
    // TODO
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
}
