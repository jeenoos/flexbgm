import 'package:flextv_bgm_player/controllers/bgm_controller.dart';
import 'package:flextv_bgm_player/model/bgm.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class BgmItem extends GetView<BgmController> {
  final Sound item;
  const BgmItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller.modify(item.id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 228, 227, 227), width: 1))),
        child: Row(
          children: [
            Expanded(
                flex: 7,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item.name),
                )),
            Visibility(
              visible: item.done.isNotEmpty,
              child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${item.done}개',
                      textAlign: TextAlign.right,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
