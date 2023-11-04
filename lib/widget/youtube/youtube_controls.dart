import 'package:flextv_bgm_player/controllers/youtube_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YoutubeControls extends GetView<YoutubeController> {
  const YoutubeControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        '준비중',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
    // Color.fromARGB(255, 36, 32, 32)      () {
    //     return Column(
    //       children: [
    //         Row(
    //           children: [
    //             IconButton(
    //               icon: Icon(
    //                 controller.controls.value.isPlaying
    //                     ? Icons.pause
    //                     : Icons.play_arrow,
    //               ),
    //               onPressed: controller.isPlayerReady
    //                   ? () {
    //                       controller.controls.value.isPlaying
    //                           ? controller.controls.pause()
    //                           : controller.controls.play();
    //                     }
    //                   : null,
    //             ),
    //             IconButton(
    //               icon: Icon(controller.muted.value
    //                   ? Icons.volume_off
    //                   : Icons.volume_up),
    //               onPressed: controller.isPlayerReady
    //                   ? () {
    //                       controller.muted.value
    //                           ? controller.controls.unMute()
    //                           : controller.controls.mute();
    //                       controller.muted.value = !controller.muted.value;
    //                     }
    //                   : null,
    //             ),
    //           ],
    //         ),
    //         Row(
    //           children: <Widget>[
    //             Expanded(
    //               child: Slider(
    //                 inactiveColor: Colors.transparent,
    //                 value: controller.volume.value,
    //                 min: 0.0,
    //                 max: 100.0,
    //                 divisions: 10,
    //                 label: '${(controller.volume).round()}',
    //                 onChanged: controller.isPlayerReady
    //                     ? (value) {
    //                         controller.volume.value = value;
    //                         controller.controls
    //                             .setVolume(controller.volume.round());
    //                       }
    //                     : null,
    //               ),
    //             ),
    //           ],
    //         ),
    //         Row(
    //           children: [
    //             loadCueButton('LOAD'),
    //             const SizedBox(width: 10.0),
    //             loadCueButton('CUE'),
    //           ],
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Widget text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Color getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  Widget get space => const SizedBox(height: 10);

  Widget loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: controller.isPlayerReady
            ? () {
                if (controller.sourceController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        controller.sourceController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') controller.controls.load(id);
                  if (action == 'CUE') controller.controls.cue(id);
                  FocusScope.of(Get.context!).requestFocus(FocusNode());
                } else {
                  showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
