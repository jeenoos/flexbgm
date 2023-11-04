import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeController extends GetxController {
  late YoutubePlayer player;
  late YoutubePlayerController controls;
  // final TextEditingController idController = TextEditingController();
  final TextEditingController seekToController = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  Rx<PlayerState> playerState = Rx(PlayerState.unknown);
  Rx<YoutubeMetaData> videoMetaData = Rx(const YoutubeMetaData());
  RxDouble volume = RxDouble(100);
  RxBool muted = RxBool(false);
  bool isPlayerReady = false;

  final List<String> ids = [
    'iLnmTe5Q2Qw',
    '_WoCV4c6XOE',
    'KmzdUe0RSJo',
    '6jZDSSZZxjQ',
    'p2lYr3vM_1w',
    '7QUtEmBT_-w',
    '34_PXCzGw1M',
  ];

  void listener() {
    if (isPlayerReady && !controls.value.isFullScreen) {
      playerState.value = controls.value.playerState;
      videoMetaData.value = controls.metadata;
    }
  }

  @override
  void dispose() {
    controls.dispose();
    sourceController.dispose();
    seekToController.dispose();
    super.dispose();
  }

  @override
  void onInit() async {
    super.onInit();
    controls = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
              "https://www.youtube.com/watch?v=DQR1UJDtI1U") ??
          "",
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    player = YoutubePlayer(
      controller: controls,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      topActions: <Widget>[
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            controls.metadata.title,
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
        debugPrint('${2222}');
        isPlayerReady = true;
      },
      onEnded: (data) {
        controls.load(ids[(ids.indexOf(data.videoId) + 1) % ids.length]);
      },
    );
  }
}
