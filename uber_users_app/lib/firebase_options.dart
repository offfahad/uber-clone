// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyDh6AR908lbefiOUkUUJsqEqBprqwtvnec',
    appId: '1:311663641676:web:1cdcbd49fcaa78eab8a0e9',
    messagingSenderId: '311663641676',
    projectId: 'everyone-2de50',
    authDomain: 'everyone-2de50.firebaseapp.com',
    databaseURL: 'https://everyone-2de50-default-rtdb.firebaseio.com',
    storageBucket: 'everyone-2de50.appspot.com',
    measurementId: 'G-VJQEG7SJT2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMTI-xVId1DTz9DS0-LEJZhF-eAFv352c',
    appId: '1:311663641676:android:e4cf8001ceacd074b8a0e9',
    messagingSenderId: '311663641676',
    projectId: 'everyone-2de50',
    databaseURL: 'https://everyone-2de50-default-rtdb.firebaseio.com',
    storageBucket: 'everyone-2de50.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFWNtdbcB4KYEV4xSHLsO8HUo-hsFjS1U',
    appId: '1:311663641676:ios:c1f13597a6d47f56b8a0e9',
    messagingSenderId: '311663641676',
    projectId: 'everyone-2de50',
    databaseURL: 'https://everyone-2de50-default-rtdb.firebaseio.com',
    storageBucket: 'everyone-2de50.appspot.com',
    iosBundleId: 'com.example.uberUsersApp',
  );

}