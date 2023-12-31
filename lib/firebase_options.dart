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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
      apiKey: "AIzaSyB_KiRXR9Se9E1S8NoMisBCTMOSxWqlr24",
      authDomain: "new-raipur-home.firebaseapp.com",
      projectId: "new-raipur-home",
      storageBucket: "new-raipur-home.appspot.com",
      messagingSenderId: "540537989061",
      appId: "1:540537989061:web:a4a3f29394b0e0de660dac",
      measurementId: "G-0GGVC96QMW"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_KiRXR9Se9E1S8NoMisBCTMOSxWqlr24',
    appId: '1:540537989061:android:ebdbc7a5740ad150660dac',
    messagingSenderId: "540537989061",
    projectId: 'new-raipur-home',
    storageBucket: "new-raipur-home.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsuxFQVKBoURt070e56_GxUWDglHGT5d0',
    appId: '1:63168540332:ios:0d980b41297ce2ef623909',
    messagingSenderId: '63168540332',
    projectId: 'ebroker-wrteam',
    storageBucket: 'ebroker-wrteam.appspot.com',
    iosClientId: '63168540332-b8snl3ggfeaosrq8acqc11npalhouus5.apps.googleusercontent.com',
    iosBundleId: 'com.ebroker.wrteam',
  );
}
