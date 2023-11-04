import 'package:flextv_bgm_player/controllers/youtube_controller.dart';
import 'package:flextv_bgm_player/widget/youtube/youtube_controls.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Youtube extends GetView<YoutubeController> {
  const Youtube({super.key});

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: controller.controls,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              controller.controls.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              ('Settings Tapped!');
            },
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          // TotalDuration(),
        ],
        onReady: () {
          controller.isPlayerReady = true;
        },
        onEnded: (data) {
          controller.controls.load(controller.ids[
              (controller.ids.indexOf(data.videoId) + 1) %
                  controller.ids.length]);
          showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) {
        return Container(
          // margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.amber,
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: <Widget>[
                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(width: 1, color: Colors.black87),
                    ),
                  ),
                  child: player,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    // color: Colors.yellow,
                    child: const SizedBox(
                      width: 200.0,
                      child: YoutubeControls(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _text(String title, String value) {
  //   return RichText(
  //     text: TextSpan(
  //       text: '$title : ',
  //       style: const TextStyle(
  //         color: Colors.blueAccent,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       children: [
  //         TextSpan(
  //           text: value,
  //           style: const TextStyle(
  //             color: Colors.blueAccent,
  //             fontWeight: FontWeight.w300,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Color _getStateColor(PlayerState state) {
  //   switch (state) {
  //     case PlayerState.unknown:
  //       return Colors.grey[700]!;
  //     case PlayerState.unStarted:
  //       return Colors.pink;
  //     case PlayerState.ended:
  //       return Colors.red;
  //     case PlayerState.playing:
  //       return Colors.blueAccent;
  //     case PlayerState.paused:
  //       return Colors.orange;
  //     case PlayerState.buffering:
  //       return Colors.yellow;
  //     case PlayerState.cued:
  //       return Colors.blue[900]!;
  //     default:
  //       return Colors.blue;
  //   }
  // }

  // Widget get _space => const SizedBox(height: 10);

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
