import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Bgm {
  final String? loginId;
  final List<Sound> playlist;
  Bgm({
    required this.loginId,
    required this.playlist,
  });

  factory Bgm.fromMap(Map<String, dynamic> map) {
    Bgm bgm = Bgm(
      loginId: map['loginId'] as String,
      playlist: List<Sound>.from(
        (map['playlist'] as List<dynamic>).map<Sound>(
          (x) => Sound.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
    return bgm;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playlist': playlist.map((x) => x.toMap()).toList(),
      'loginId': loginId,
    };
  }

  String toJson() => json.encode(toMap());

  factory Bgm.fromJson(String source) =>
      Bgm.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Sound {
  final String id;
  final String name;
  final SoundSource source;
  final String done;
  Sound({
    required this.id,
    required this.name,
    required this.source,
    required this.done,
  });

  factory Sound.fromMap(Map<String, dynamic> map) {
    return Sound(
      id: map['id'] as String,
      name: map['name'] as String,
      source: SoundSource.fromMap(map['source']),
      done: map['done'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'source': source.toMap(),
      'done': done,
    };
  }

  get value => null;
}

class SoundSource {
  final SoundSourceType type;
  final String uri;
  const SoundSource({required this.type, required this.uri});

  factory SoundSource.fromMap(Map<String, dynamic> map) {
    return SoundSource(type: SoundSourceType.get(map['type']), uri: map['uri']);
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type.value, 'uri': uri};
  }
}

enum SoundSourceType {
  file('file', '파일', FontAwesomeIcons.recordVinyl, ''),
  youtube('youtube', '유튜브', FontAwesomeIcons.youtube,
      'https://youtu.be/example?feature=shared'),
  url('url', '주소', Icons.link, 'https://example.com/bgm.mp3');

  final String value;
  final String label;
  final String hint;
  final IconData icon;
  const SoundSourceType(this.value, this.label, this.icon, this.hint);
  static SoundSourceType get(name) =>
      SoundSourceType.values.firstWhere((element) => element.name == name);
}

get soundSourceTypes => SoundSourceType.values.toList();
