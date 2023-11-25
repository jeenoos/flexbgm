import 'package:audio_session/audio_session.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/audio/audio_common.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

// import 'package:rxdart/rxdart.dart';
enum PlayState { loading, buffering, ready, paused, playing, stoped }

enum RepeatState { off, repeatSong, repeatPlaylist }

class SoundController extends GetxController with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final RxBool isEdit = RxBool(false);
  final RxnDouble drag = RxnDouble(null);
  final Rxn<RangeValues> range = Rxn(null);
  final Rx<PlayState> playState = Rx(PlayState.loading);
  final Rx<RepeatState> repeatState = Rx(RepeatState.off);
  final Rx<ProgressState> progressState = Rx(const ProgressState(
      buffered: Duration.zero, current: Duration.zero, total: Duration.zero));
  final Rxn<IndexedAudioSource> currentSource = Rxn(null);
  final RxList<IndexedAudioSource> playlist = RxList([]);
  final RxBool isShuffle = RxBool(false);
  final RxBool isFirst = RxBool(true);
  final RxBool isLast = RxBool(true);

  TextEditingController urlController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  AudioPlayer get player => _player;
  String get title => currentSource.value?.tag as String? ?? '';
  List<String> get titles => [];

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
    Duration? res = await _player.load();
    if (res != null) {
      double duration = res.inMilliseconds.toDouble();
      range.value = RangeValues(0.0, duration);
    }
  }

  void setPlaylist(List<Sound> items) async {
    List<AudioSource> list = items.map((e) {
      return e.source.type == SoundSourceType.file
          ? AudioSource.file(e.source.uri, tag: e.name)
          : AudioSource.uri(Uri.parse(e.source.uri), tag: e.name);
    }).toList();
    // playlist.value = list;
    await player.setAudioSource(
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: list,
      ),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
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
  }

  void seekAndPlay(double position) async {
    await _player.seek(Duration(milliseconds: position.toInt()));
    _player.play();
  }

  void play() async {
    isEdit.value ? seekAndPlay(range.value?.start ?? 0) : _player.play();
    playState.value = PlayState.playing;
  }

  void stop() {
    _player.stop();
  }

  void pause() {
    _player.pause();
    playState.value = PlayState.paused;
  }

  void next() {
    _player.seekToNext();
  }

  void prev() {
    _player.seekToPrevious();
  }

  void shuffle() {
    _player.setShuffleModeEnabled(true);
  }

  void repeat() {
    _player.setLoopMode(LoopMode.all);
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _listenForChangesInPlayerClip();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

  void _listenForChangesInPlayerClip() {
    isEdit.listen((edit) async {
      Duration start = Duration(milliseconds: range.value?.start.toInt() ?? 0);
      Duration end = Duration(milliseconds: range.value?.end.toInt() ?? 0);
      edit
          ? await _player.setClip()
          : await _player.setClip(start: start, end: end);
      edit ? await _player.seek(start) : await _player.seek(Duration.zero);
      _player.stop();
    });
  }

  void _listenForChangesInPlayerState() {
    _player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        if (playState.value != PlayState.playing) {
          playState.value = PlayState.loading;
        }
      } else if (processingState == ProcessingState.ready) {
        if (playState.value != PlayState.playing) {
          playState.value = PlayState.ready;
        }
      } else if (!playerState.playing) {
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

      if (position >
          (isEdit.value
              ? range.value!.end.milliseconds
              : progressState.value.total)) {
        pause();
      }
      // debugPrint('changesInPlayerPosition: ${position.toString()}');
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
      // debugPrint('changesInBufferedPosition: ${bufferedPosition.toString()}');
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
      // debugPrint('changesInTotalDuration: ${totalDuration.toString()}');
    });
  }

  void _listenForChangesInSequenceState() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final currentItem = sequenceState.currentSource;
      final index = sequenceState.currentIndex;

      currentSource.value = currentItem;
      final list = sequenceState.effectiveSequence;
      playlist.value = list;
      // update previous and next buttons
      if (list.isEmpty || currentSource.value == null) {
        isFirst.value = true;
        isLast.value = true;
      } else {
        isFirst.value = list.first == currentItem;
        isLast.value = list.last == currentItem;
      }
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
