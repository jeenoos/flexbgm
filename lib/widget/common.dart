import 'package:just_audio/just_audio.dart';

enum PlayState { loading, buffering, ready, paused, playing, stoped }

// Feed your own stream of bytes into the player
class BgmSource extends StreamAudioSource {
  final List<int> bytes;
  BgmSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mp3',
    );
  }
}
