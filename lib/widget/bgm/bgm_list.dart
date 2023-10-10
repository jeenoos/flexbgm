import 'package:flextv_bgm_player/controllers/bgm_controller.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flextv_bgm_player/widget/bgm/bgm_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BgmList extends GetView<BgmController> {
  const BgmList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
          () => ReorderableListView.builder(
            header: Container(
              color: Colors.black54,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 50),
                    child: const Text(
                      '재생목록',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 100),
                    child: const Text(
                      '후원',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final Sound item = controller.items[index];
              return Container(
                key: ValueKey(item.id),
                child: BgmItem(item: item),
              );
            },
            onReorder: (oldIndex, newIndex) =>
                controller.swap(oldIndex, newIndex),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), //모서리
          ), //테두리
          onPressed: () => Get.find<BgmController>().regist(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }
}
