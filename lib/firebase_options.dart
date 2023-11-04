// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBcQ4agMOYjIm_Lld7mr7a_-M9ARpIIg7Y',
    appId: '1:292898813989:web:1a9792fdc03d8f7d1067cc',
    messagingSenderId: '292898813989',
    projectId: 'flexbgm-3f5d4',
    authDomain: 'flexbgm-3f5d4.firebaseapp.com',
    storageBucket: 'flexbgm-3f5d4.appspot.com',
    measurementId: 'G-BEPR5NMBP1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAi05b_K0v8lQ-NPTI0czLav0nOENHeMPw',
    appId: '1:292898813989:android:5827d19fa97aa7751067cc',
    messagingSenderId: '292898813989',
    projectId: 'flexbgm-3f5d4',
    storageBucket: 'flexbgm-3f5d4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMITYOpVRj8s8prhf_MiWEb7CzfBEuAY8',
    appId: '1:292898813989:ios:3aaf73fea0f1f44d1067cc',
    messagingSenderId: '292898813989',
    projectId: 'flexbgm-3f5d4',
    storageBucket: 'flexbgm-3f5d4.appspot.com',
    iosBundleId: 'com.example.flextvBgmPlayer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMITYOpVRj8s8prhf_MiWEb7CzfBEuAY8',
    appId: '1:292898813989:ios:80d3582ffc079dc51067cc',
    messagingSenderId: '292898813989',
    projectId: 'flexbgm-3f5d4',
    storageBucket: 'flexbgm-3f5d4.appspot.com',
    iosBundleId: 'com.example.flextvBgmPlayer.RunnerTests',
  );
}
