import 'package:flextv_bgm_player/controllers/bgm_controller.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/audio/audio_player.dart';

// import 'package:flextv_bgm_player/widget/audio/player_widget.dart';
import 'package:flextv_bgm_player/widget/text_input.dart';
import 'package:flextv_bgm_player/widget/youtube/youtube_player.dart';
// import 'package:flextv_bgm_player/widget/youtube/youtube_player';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Editor extends GetView<BgmController> {
  const Editor({super.key});
  static const route = '/editor';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            toolbarHeight: 60,
            centerTitle: false,
            automaticallyImplyLeading: true,
            backgroundColor: Colors.black87,
            title: Text(
                controller.status.value == EditingStatus.regist ? '등록' : '편집',
                style: const TextStyle(color: Colors.white, fontSize: 16))),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<SoundSourceType>(
                    style: ButtonStyle(
                      iconColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) =>
                              states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : Colors.redAccent),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) =>
                              states.contains(MaterialState.selected)
                                  ? Colors.black87
                                  : Colors.white),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                        return states.contains(MaterialState.selected)
                            ? Colors.white
                            : Colors.black87;
                      }),
                    ),
                    segments: SoundSourceType.values.map((SoundSourceType e) {
                      return ButtonSegment(
                          value: SoundSourceType.get(e.value),
                          label: Text(e.label),
                          icon: Icon(e.icon));
                    }).toList(),
                    selected: <SoundSourceType>{controller.sourceType.value},
                    onSelectionChanged: (Set<SoundSourceType> newSelection) {
                      // controller.sourceController.text = '';
                      controller.sourceType.value = newSelection.first;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          enabled: controller.sourceType.value !=
                              SoundSourceType.file,
                          controller: controller.sourceController,
                          decoration: InputDecoration(
                            hintText: controller.sourceType.value.hint,
                            errorText: controller.errorSource.value,
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(height: 0.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 10.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black87,
                            shadowColor: Colors.grey,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            minimumSize: const Size(100, 65), //////// HERE
                          ),
                          onPressed: () => controller.sourceType.value ==
                                  SoundSourceType.file
                              ? controller.pick()
                              : controller.load(),
                          child: controller.sourceType.value ==
                                  SoundSourceType.file
                              ? const Text('파일선택')
                              : const Text('불러오기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: controller.sourceType.value == SoundSourceType.youtube,
                child: const Youtube(),
              ),
              Visibility(
                visible: controller.sourceType.value != SoundSourceType.youtube,
                child: AudioPlayer(),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: controller.sourceType.value != SoundSourceType.youtube,
                child: Column(
                  children: [
                    TextInput(
                      height: 56,
                      hintText: '후원 설정',
                      controller: controller.doneController,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: controller.sourceType.value != SoundSourceType.youtube,
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.black87,
                                  textStyle: const TextStyle(fontSize: 14)),
                              onPressed: () => controller.save(Get.arguments),
                              child: const Row(
                                children: [
                                  Icon(FontAwesomeIcons.check,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 10),
                                  Text(
                                    '저장',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible:
                                controller.status.value == EditingStatus.modify,
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.red,
                                    textStyle: const TextStyle(fontSize: 14)),
                                onPressed: () =>
                                    controller.delete(Get.arguments),
                                child: const Row(
                                  children: [
                                    Icon(Icons.clear,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text('삭제',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
