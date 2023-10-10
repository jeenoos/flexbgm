import 'dart:convert';

class User {
  final String loginId;
  final String nickname;
  final String name;
  final String thumbUrl;
  final Oauth? oauth;
  final int channelId;
  final Fan fan;
  final int luv;
  final String role;
  final int sms;
  final int id;
  final int condition;
  final String phone;
  final int status;
  final bool isAdult;
  final Pi PI;
  final bool ranker;
  final int memberDiv;
  final int appPush;
  final int msgCount;
  final bool signature;
  final BillboardIs billboardIs;
  final int isBigFan;
  final int isAdultCheck;
  final Setting setting;
  final ChannelStop? channelStop;
  final Token token;

  User({
    required this.loginId,
    required this.nickname,
    required this.name,
    required this.thumbUrl,
    required this.oauth,
    required this.channelId,
    required this.fan,
    required this.luv,
    required this.role,
    required this.sms,
    required this.id,
    required this.condition,
    required this.phone,
    required this.status,
    required this.isAdult,
    required this.PI,
    required this.ranker,
    required this.memberDiv,
    required this.appPush,
    required this.msgCount,
    required this.signature,
    required this.billboardIs,
    required this.isBigFan,
    required this.isAdultCheck,
    required this.setting,
    required this.channelStop,
    required this.token,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      loginId: map['loginId'] as String,
      nickname: map['nickname'] as String,
      name: map['name'] as String,
      thumbUrl: map['thumbUrl'] as String,
      oauth: map['oauth'] != null
          ? Oauth.fromMap(map['oauth'] as Map<String, dynamic>)
          : null,
      channelId: map['channelId'].toInt() as int,
      fan: Fan.fromMap(map['fan'] as Map<String, dynamic>),
      luv: map['luv'].toInt() as int,
      role: map['role'] as String,
      sms: map['sms'].toInt() as int,
      id: map['id'].toInt() as int,
      condition: map['condition'].toInt() as int,
      phone: map['phone'] as String,
      status: map['status'].toInt() as int,
      isAdult: map['isAdult'] as bool,
      PI: Pi.fromMap(map['PI'] as Map<String, dynamic>),
      ranker: map['ranker'] as bool,
      memberDiv: map['memberDiv'].toInt() as int,
      appPush: map['appPush'].toInt() as int,
      msgCount: map['msgCount'].toInt() as int,
      signature: map['signature'] as bool,
      billboardIs:
          BillboardIs.fromMap(map['billboardIs'] as Map<String, dynamic>),
      isBigFan: map['isBigFan'].toInt() as int,
      isAdultCheck: map['isAdultCheck'].toInt() as int,
      setting: Setting.fromMap(map['setting'] as Map<String, dynamic>),
      channelStop: map['channelStop'] != null
          ? ChannelStop.fromMap(map['channelStop'] as Map<String, dynamic>)
          : null,
      token: Token.fromMap(map['token'] as Map<String, dynamic>),
    );
  }
}

class Oauth {
  final String provider;
  Oauth({
    required this.provider,
  });

  factory Oauth.fromMap(Map<String, dynamic> map) {
    return Oauth(
      provider: map['provider'] as String,
    );
  }
}

class Fan {
  final int rating;
  Fan({
    required this.rating,
  });

  factory Fan.fromMap(Map<String, dynamic> map) {
    return Fan(
      rating: map['rating'].toInt() as int,
    );
  }
}

class Pi {
  final bool isAdult;
  Pi({
    required this.isAdult,
  });

  factory Pi.fromMap(Map<String, dynamic> map) {
    return Pi(
      isAdult: map['isAdult'] as bool,
    );
  }
}

class BillboardIs {
  final int billboardIsView;
  final int billboardIsVibes;
  final int billboardIsSponser;
  BillboardIs({
    required this.billboardIsView,
    required this.billboardIsVibes,
    required this.billboardIsSponser,
  });

  factory BillboardIs.fromMap(Map<String, dynamic> map) {
    return BillboardIs(
      billboardIsView: map['billboardIsView'].toInt() as int,
      billboardIsVibes: map['billboardIsVibes'].toInt() as int,
      billboardIsSponser: map['billboardIsSponser'].toInt() as int,
    );
  }
}

class Setting {
  final int memberSortCode;
  Setting({
    required this.memberSortCode,
  });

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      memberSortCode: map['memberSortCode'].toInt() as int,
    );
  }
}

class ChannelStop {
  ChannelStop();
  factory ChannelStop.fromMap(Map<String, dynamic> map) {
    return ChannelStop();
  }
}

class Token {
  final int user_id;
  final String user_loginId;
  final String user_name;
  final String user_nickname;
  final String accessToken;
  final int accessToken_expire;
  final int accessToken_ttl;
  final String refreshToken;
  final int refreshToken_ttl;
  final int refreshToken_expire;
  Token({
    required this.user_id,
    required this.user_loginId,
    required this.user_name,
    required this.user_nickname,
    required this.accessToken,
    required this.accessToken_expire,
    required this.accessToken_ttl,
    required this.refreshToken,
    required this.refreshToken_ttl,
    required this.refreshToken_expire,
  });

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      user_id: map['user_id'].toInt() as int,
      user_loginId: map['user_loginId'] as String,
      user_name: map['user_name'] as String,
      user_nickname: map['user_nickname'] as String,
      accessToken: map['accessToken'] as String,
      accessToken_expire: map['accessToken_expire'].toInt() as int,
      accessToken_ttl: map['accessToken_ttl'].toInt() as int,
      refreshToken: map['refreshToken'] as String,
      refreshToken_ttl: map['refreshToken_ttl'].toInt() as int,
      refreshToken_expire: map['refreshToken_expire'].toInt() as int,
    );
  }
}
