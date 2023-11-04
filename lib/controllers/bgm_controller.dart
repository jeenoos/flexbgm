// import 'package:audioplayers/audioplayers.dart';

import 'package:flextv_bgm_player/controllers/sound_controller.dart';
// import 'package:flextv_bgm_player/controllers/youtube_controller';
import 'package:flutter/foundation.dart';
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

class BgmController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final SoundController soundController = Get.find<SoundController>();
  // final YoutubeController youtubeController = Get.find<YoutubeController>();
  final Rx<EditingStatus> status = Rx(EditingStatus.done);
  final RxList<Sound> items = RxList();
  final Rx<SoundSourceType> sourceType = Rx(SoundSourceType.file);

  // final Rx<SourceType> sourceType = Rx(SourceType.file);
  final RxString name = RxString('제목 없음');
  final RxnString errorName = RxnString(null);
  final RxnString errorSource = RxnString(null);
  Bgm? respose;
  User? user;

  //소스
  TextEditingController get sourceController {
    switch (sourceType.value) {
      case SoundSourceType.file:
      case SoundSourceType.url:
        return soundController.sourceController;
      case SoundSourceType.youtube:
        return soundController.sourceController;
    }
  }

  //렉스
  TextEditingController doneController = TextEditingController();

  static BgmController get to => Get.find();

  void regist() {
    status.value = EditingStatus.regist;
    Get.toNamed(AppRoutes.editor);
    reset();
  }

  void swap(int oldIndex, int newIndex) {
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    Sound item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    items.refresh();
    submit();
  }

  void modify(String id) async {
    status.value = EditingStatus.modify;
    Sound item = items.firstWhere((e) => e.id == id);
    sourceController.text = item.source.uri;
    doneController.text = item.done;

    soundController
        .play(SoundSource(type: item.source.type, uri: item.source.uri));
    Get.toNamed(AppRoutes.editor, arguments: id);
  }

  void delete(String id) {
    status.value = EditingStatus.delete;
    items.removeWhere((e) => e.id == id);
    items.refresh();
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
      name.value = basenameWithoutExtension(path);
      sourceController.text = path;
    } else {
      sourceController.text = '파일 경로를 찾을 수 없습니다.';
    }
  }

  Sound create(String? id) {
    return Sound(
      id: id ?? uuid.v4(),
      name: name.value,
      source: SoundSource(type: sourceType.value, uri: sourceController.text),
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
    sourceController.text = '';
    doneController.text = '';
    errorName.value = null;
    errorSource.value = null;
  }

  void save(String? id) {
    if (validation()) {
      Sound newItem = create(id);
      Sound regacyItem = items.firstWhere((e) => e.id == id);
      // 데이터 같으면 저장 안함
      if (mapEquals(regacyItem.toMap(), newItem.toMap())) {
        return Get.back();
      }
      switch (status.value) {
        case EditingStatus.modify:
          int index = items.indexWhere((e) => e.id == id);
          items[index] = newItem;
          break;
        case EditingStatus.regist:
          items.add(newItem);
        default:
          break;
      }
      items.refresh();
      submit();
      Get.back();
    }
  }

  void submit() {
    firestore
        .collection('bgm')
        // .doc(user?.id.toString())
        .doc('17483')
        .update({"playlist": items.map((e) => e.toMap()).toList()});
  }

  Future<Bgm> load() async {
    DocumentSnapshot<Map<String, dynamic>> response =
        // await firestore.collection('bgm').doc(_user?.id.toString()).get();
        await firestore.collection('bgm').doc('17483').get();
    Map<String, dynamic>? data = response.data();
    return Bgm.fromMap(data ?? {});
  }

  @override
  onInit() async {
    super.onInit();
    respose = await load();
    debugPrint('respose: ${respose}');
    items.value = respose?.playlist ?? [];
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
  }
}
