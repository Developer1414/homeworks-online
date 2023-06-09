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
    apiKey: 'AIzaSyDQ35Ymt7C_muGM0TFQcVooIsSx-exycSk',
    appId: '1:371990022456:web:50209bf1c5b78c3c8599cd',
    messagingSenderId: '371990022456',
    projectId: 'school-homeworking-online',
    authDomain: 'school-homeworking-online.firebaseapp.com',
    storageBucket: 'school-homeworking-online.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEOXx7BMjpEZYqwnvpq1vg_mRVIr2Aq60',
    appId: '1:371990022456:android:e55ace294200d8de8599cd',
    messagingSenderId: '371990022456',
    projectId: 'school-homeworking-online',
    storageBucket: 'school-homeworking-online.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0vjAJW8x9IphMUFw8XurA2HHolEsYZDQ',
    appId: '1:371990022456:ios:f705c2dfd6e172398599cd',
    messagingSenderId: '371990022456',
    projectId: 'school-homeworking-online',
    storageBucket: 'school-homeworking-online.appspot.com',
    iosClientId: '371990022456-b2icgi450ds570gdv4g3p56qsel9as4n.apps.googleusercontent.com',
    iosBundleId: 'com.example.scoolHomeWorking',
  );
}
