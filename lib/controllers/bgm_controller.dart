// import 'package:audioplayers/audioplayers.dart';

import 'dart:ffi';
import 'dart:math';

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
  final Rxn<Sound> currentSound = Rxn(null);
  final RxInt currentIndex = RxInt(0);
  final RxInt current = RxInt(0);
  final RxInt total = RxInt(0);
  final RxInt buffer = RxInt(0);
  final RxInt start = RxInt(0);
  final RxInt end = RxInt(0);
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
  final RxString routeName = RxString('/home');

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
  String get title => currentSound.value?.name ?? '';

  void setPlaylist(List<Sound> items) async {
    List<AudioSource> list = items.map((e) {
      return e.source.type == SoundSourceType.file
          ? AudioSource.file(e.source.uri, tag: e.name)
          : AudioSource.uri(Uri.parse(e.source.uri), tag: e.name);
    }).toList();
    // playlist.value = list;
    // await _player.setAudioSource(
    //   ConcatenatingAudioSource(
    //     useLazyPreparation: true,
    //     shuffleOrder: DefaultShuffleOrder(),
    //     children: list,
    //   ),
    //   initialIndex: 0,
    //   initialPosition: Duration.zero,
    // );
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
    // playState.value = PlayState.playing;
    // await _player.seek(Duration(milliseconds: start.value.toInt()));
    await _player.play();
  }

  void stop() async {
    await _player.seek(Duration.zero);
    // playState.value = PlayState.stoped;
    await _player.stop();
  }

  void pause() async {
    // playState.value = PlayState.paused;
    await _player.pause();
  }

  void next() async {
    int nextIndex = currentIndex.value + 1;
    if (nextIndex < sounds.length) {
      currentSound.value = sounds.elementAt(nextIndex);
      currentIndex.value = nextIndex;
      setSoundByIndex(nextIndex);
    } else {
      stop();
      debugPrint('stop');
    }
  }

  void prev() async {
    int nextIndex = currentIndex.value - 1;
    currentSound.value = sounds.elementAt(nextIndex);
    currentIndex.value = nextIndex;
    setSoundByIndex(nextIndex);
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

  void _sourceTypeListener(value) {
    soundController.stop();
  }

  void _listenForChangesRouteName() {
    routeName.listen((name) async {
      debugPrint('name: ${name}');
      if (name == '/editor') {
        await _player.pause();
      }
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
        next();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _player.positionStream.listen((position) {
      current.value = position.inMilliseconds;
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

  void setSoundByIndex(int index) async {
    Sound? sound = sounds.elementAt(index);
    RangeValues range = sound.source.range;
    start.value = range.start.toInt();
    end.value = range.end.toInt();
    currentIndex.value = index;
    currentSound.value = sound;
    isFirst.value = sounds.first == sound;
    isLast.value = sounds.last == sound;
    await setUri(sound.source.uri);
    await _player.load();
    await _player.setClip(
      start: Duration(milliseconds: range.start.toInt()),
      end: Duration(milliseconds: range.end.toInt()),
    );
  }

  Future<Bgm> connection() async {
    DocumentSnapshot<Map<String, dynamic>> response =
        // await firestore.collection('bgm').doc(_user?.id.toString()).get();
        await firestore.collection('bgm').doc('17483').get();
    Map<String, dynamic>? data = response.data();
    return Bgm.fromMap(data ?? {});
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    respose = await connection();
    List<Sound> list = respose?.playlist ?? [];
    if (list.isNotEmpty) {
      sounds.value = list;
      setSoundByIndex(0);
    }

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

    _listenForChangesRouteName();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
  }
}
