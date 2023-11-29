import 'package:audio_session/audio_session.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

// import 'package:rxdart/rxdart.dart';

class SoundController extends GetxController with WidgetsBindingObserver {
  final _player = AudioPlayer();

  final RxBool isEdit = RxBool(false);
  final RxnDouble drag = RxnDouble(null);
  final Rx<RangeValues> range = Rx(const RangeValues(0.0, 0.0));
  final RxInt current = RxInt(0);
  final RxInt total = RxInt(0);
  final RxInt buffer = RxInt(0);

  final Rx<PlayState> playState = Rx(PlayState.loading);

  final RxList<IndexedAudioSource> playlist = RxList([]);

  final RxString routeName = RxString('/home');

  AudioPlayer get player => _player;

  bool get isHome => routeName.value == '/home';

  @override
  void onInit() async {
    super.onInit();
    _init();
  }

  Future<void> setUri(String path) async {
    Uri uri = Uri.parse(path);
    if (uri.isScheme('https') || uri.isScheme('http')) {
      // Catching errors at load time
      try {
        await _player.setUrl(path);
      } on PlayerException catch (e) {
        // iOS/macOS: maps to NSError.code
        // Android: maps to ExoPlayerException.type
        // Web: maps to MediaError.code
        // Linux/Windows: maps to PlayerErrorCode.index
        debugPrint("Error code: ${e.code}");
        // iOS/macOS: maps to NSError.localizedDescription
        // Android: maps to ExoPlaybackException.getMessage()
        // Web/Linux: a generic message
        // Windows: MediaPlayerError.message
        debugPrint("Error message: ${e.message}");
      } on PlayerInterruptedException catch (e) {
        // This call was interrupted since another audio source was loaded or the
        // player was stopped or disposed before this audio source could complete
        // loading.
        debugPrint("Connection aborted: ${e.message}");
      } catch (e) {
        // Fallback for all other errors
        debugPrint('An error occured: $e');
      }
    } else {
      await _player.setFilePath(path);
    }
  }

  Future<void> setSound(Sound sound) async {
    RangeValues ranges = sound.source.range;
    range.value = ranges;
    await setUri(sound.source.uri);
    await _player
        .load()
        .then((value) => total.value = value?.inMilliseconds.toInt() ?? 0);
    _player.setClip(
      start: Duration(milliseconds: ranges.start.toInt()),
      end: Duration(milliseconds: ranges.end.toInt()),
    );
  }

  void reset() {
    debugPrint('soundcontroller reset');
    drag.value = null;
    current.value = 0;
    total.value = 0;
    buffer.value = 0;
  }

  void seekAndPlay(double position) async {
    await player.seek(Duration(milliseconds: position.toInt()));
    _player.play();
  }

  void play() async {
    debugPrint('${isEdit.value}');
    isEdit.value ? seekAndPlay(range.value.start) : _player.play();
    playState.value = PlayState.playing;
  }

  void stop() {
    _player.stop();
    playState.value = PlayState.stoped;
  }

  void pause() {
    player.pause();
    playState.value = PlayState.paused;
  }

  void seek(Duration position) {
    player.seek(position);
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _listenForChangesRouteName();
    _listenForChangesInPlayerClip();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
  }

  void _listenForChangesRouteName() {
    routeName.listen((name) async {
      if (name == '/home') {
        await _player.stop();
      }

      if (name == '/editor') {
        reset();
      }
    });
  }

  void _listenForChangesInPlayerClip() {
    isEdit.listen((edit) async {
      Duration start = Duration(milliseconds: range.value.start.toInt());
      Duration end = Duration(milliseconds: range.value.end.toInt());
      edit
          ? await player.setClip()
          : await player.setClip(start: start, end: end);
      edit ? await player.seek(start) : await player.seek(Duration.zero);
      player.stop();
    });
  }

  void _listenForChangesInPlayerState() {
    _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      final processingState = state.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playState.value = PlayState.loading;
      } else if (!isPlaying) {
        playState.value = PlayState.paused;
      } else if (processingState != ProcessingState.completed) {
        playState.value = PlayState.playing;
      } else {
        debugPrint('complete');
        stop();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _player.positionStream.listen((position) {
      current.value = position.inMilliseconds;
      int duration = isEdit.value ? range.value.end.toInt() : total.value;
      if (current.value > duration) {
        stop();
      }
    });
  }

  void _listenForChangesInBufferedPosition() {
    _player.bufferedPositionStream.listen((bufferedPosition) {
      buffer.value = bufferedPosition.inMilliseconds;
    });
  }

  void _listenForChangesInTotalDuration() {
    _player.durationStream.listen((totalDuration) {
      total.value = totalDuration?.inMilliseconds ?? 0;
    });
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
