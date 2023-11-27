// import 'package:audioplayers/audioplayers.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flextv_bgm_player/controllers/sound_controller.dart';
import 'package:flextv_bgm_player/widget/common.dart';
// import 'package:flextv_bgm_player/controllers/youtube_controller';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flextv_bgm_player/constants/app_routes.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/model/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum EditingStatus {
  done('done', '완료'),
  regist('regist', '생성'),
  modify('modify', '편집'),
  delete('delete', '삭제');

  final String value;
  final String label;
  const EditingStatus(this.value, this.label);
}

enum RepeatState { off, repeatSong, repeatPlaylist }

class BgmController extends GetxController with WidgetsBindingObserver {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final SoundController soundController = Get.find<SoundController>();
  final _player = AudioPlayer();
  final Rx<PlayState> playState = Rx(PlayState.loading);
  final Rx<RepeatState> repeatState = Rx(RepeatState.off);
  final Rxn<IndexedAudioSource> currentSource = Rxn(null);
  final RxInt index = RxInt(0);
  final RxInt current = RxInt(0);
  final RxInt total = RxInt(0);
  final RxInt buffer = RxInt(0);
  final RxBool isShuffle = RxBool(false);
  final RxBool isFirst = RxBool(true);
  final RxBool isLast = RxBool(true);

  final Rx<EditingStatus> status = Rx(EditingStatus.done);
  final RxList<Sound> sounds = RxList();
  final RxList<IndexedAudioSource> playlist = RxList([]);
  final Rx<SoundSourceType> sourceType = Rx(SoundSourceType.file);

  final RxString name = RxString('제목 없음');
  final RxnString errorName = RxnString(null);
  final RxnString errorSource = RxnString(null);

  TextEditingController urlController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  TextEditingController doneController = TextEditingController();

  Bgm? respose;
  User? user;

  //소스
  TextEditingController get sourceController {
    switch (sourceType.value) {
      case SoundSourceType.file:
        return pathController;
      case SoundSourceType.url:
        return urlController;
      case SoundSourceType.youtube:
        return urlController;
    }
  }

  //렉스
  static BgmController get to => Get.find();
  String get title => currentSource.value?.tag as String? ?? '';

  void setPlaylist(List<Sound> items) async {
    List<AudioSource> list = items.map((e) {
      return e.source.type == SoundSourceType.file
          ? AudioSource.file(e.source.uri, tag: e.name)
          : AudioSource.uri(Uri.parse(e.source.uri), tag: e.name);
    }).toList();
    // playlist.value = list;
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: list,
      ),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
  }

  void regist() {
    status.value = EditingStatus.regist;
    Get.toNamed(AppRoutes.editor);
    reset();
  }

  void swap(int oldIndex, int newIndex) {
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    Sound item = sounds.removeAt(oldIndex);
    sounds.insert(newIndex, item);
    sounds.refresh();
    submit();
  }

  void modify(String id) async {
    status.value = EditingStatus.modify;
    Sound item = sounds.firstWhere((e) => e.id == id);
    sourceType.value = item.source.type;
    sourceController.text = item.source.uri;
    doneController.text = item.done;
    soundController.setSound(item);
    Get.toNamed(AppRoutes.editor, arguments: id);
  }

  void delete(String id) {
    status.value = EditingStatus.delete;
    sounds.removeWhere((e) => e.id == id);
    sounds.refresh();
    submit();
    Get.back();
  }

  void pick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg'],
    );
    if (result != null) {
      String path = result.files.single.path!;
      pathController.text = path;
    } else {
      pathController.text = '파일 경로를 찾을 수 없습니다.';
    }
    load();
  }

  void load() {
    if (sourceController.text.isEmpty) {
      errorSource.value = 'URL 주소를 입력 해주세요';
      return;
    }

    name.value = basenameWithoutExtension(sourceController.text);
    soundController.setUri(sourceController.text);
  }

  void play() async {
    _player.play();
    playState.value = PlayState.playing;
  }

  void stop() {
    _player.stop();
    playState.value = PlayState.stoped;
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

  Sound create(String? id) {
    return Sound(
      id: id ?? uuid.v4(),
      name: basenameWithoutExtension(sourceController.text),
      source: SoundSource(
        type: sourceType.value,
        uri: sourceController.text,
        range: soundController.range.value,
      ),
      done: doneController.text,
    );
  }

  bool validation() {
    if (sourceController.text.isEmpty) {
      errorSource.value = '경로를 설정 해주세요.';
      return false;
    }
    return true;
  }

  void reset() {
    soundController.reset();
    doneController.text = '';
    errorName.value = null;
    errorSource.value = null;
  }

  void save(String? id) {
    if (validation()) {
      Sound newItem = create(id);
      debugPrint('newItem: ${newItem.name}');
      switch (status.value) {
        case EditingStatus.modify:
          Sound regacyItem = sounds.firstWhere((e) => e.id == id);
          // 데이터 같으면 저장 안함
          if (mapEquals(regacyItem.toMap(), newItem.toMap())) {
            return Get.back();
          }
          int index = sounds.indexWhere((e) => e.id == id);
          sounds[index] = newItem;
          break;
        case EditingStatus.regist:
          sounds.add(newItem);
        default:
          break;
      }

      playlist.refresh();
      submit();
      Get.back();
    }
  }

  void submit() {
    firestore
        .collection('bgm')
        // .doc(user?.id.toString())
        .doc('17483')
        .update({"playlist": sounds.map((e) => e.toMap()).toList()});
  }

  Future<Bgm> connection() async {
    DocumentSnapshot<Map<String, dynamic>> response =
        // await firestore.collection('bgm').doc(_user?.id.toString()).get();
        await firestore.collection('bgm').doc('17483').get();
    Map<String, dynamic>? data = response.data();
    return Bgm.fromMap(data ?? {});
  }

  void _sourceTypeListener(value) {
    soundController.stop();
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
      current.value = position.inMilliseconds;
      if (current.value > total.value) {
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

  void _listenForChangesInSequenceState() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final currentItem = sequenceState.currentSource;
      currentSource.value = currentItem;

      final list = sequenceState.effectiveSequence;
      playlist.value = list;
      index.value = sequenceState.currentIndex;

      final audio = sounds.elementAt(index.value);
      RangeValues range = audio.source.range;
      current.value = range.start.toInt();
      total.value = range.end.toInt();
      _player.seek(Duration(milliseconds: current.value));

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
  Future<void> onInit() async {
    super.onInit();
    respose = await connection();
    List<Sound> list = respose?.playlist ?? [];
    sounds.value = list;
    setPlaylist(list);
    sourceType.listen(_sourceTypeListener);

    debounce(
        errorName,
        (callback) => Future.delayed(
            const Duration(seconds: 2), () => errorName.value = null));
    debounce(
        errorSource,
        (callback) => Future.delayed(
            const Duration(seconds: 2), () => errorSource.value = null));
    // Get.find<AuthController>().user.listen((user) async {
    //   _user = user;
    //   _bgm = await load();
    //   _items(_bgm?.playlist ?? []);
    // });

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // _listenForChangesRouteName();

    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }
}
