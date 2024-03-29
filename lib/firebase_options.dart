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
    apiKey: 'AIzaSyDyFechc2lEQWG6WrzG99GZAfPArIWZK0A',
    appId: '1:600076744637:web:649fe753793d10a36c44d4',
    messagingSenderId: '600076744637',
    projectId: 'advmobiledev-studenthub-clc20',
    authDomain: 'advmobiledev-studenthub-clc20.firebaseapp.com',
    storageBucket: 'advmobiledev-studenthub-clc20.appspot.com',
    measurementId: 'G-X7PPC5YLY5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWzjVKqBHol3ejgxvcQY1Oc_nR1JIhycA',
    appId: '1:600076744637:android:20e3d62d250e6dc96c44d4',
    messagingSenderId: '600076744637',
    projectId: 'advmobiledev-studenthub-clc20',
    storageBucket: 'advmobiledev-studenthub-clc20.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCH2yYQJ93Y1P-vs8R7mR9TaGUsQHVAGZc',
    appId: '1:600076744637:ios:970f55e5ff1fc93e6c44d4',
    messagingSenderId: '600076744637',
    projectId: 'advmobiledev-studenthub-clc20',
    storageBucket: 'advmobiledev-studenthub-clc20.appspot.com',
    iosBundleId: 'com.iotecksolutions.flutterBoilerplateProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCH2yYQJ93Y1P-vs8R7mR9TaGUsQHVAGZc',
    appId: '1:600076744637:ios:760c1f3105cb1fe26c44d4',
    messagingSenderId: '600076744637',
    projectId: 'advmobiledev-studenthub-clc20',
    storageBucket: 'advmobiledev-studenthub-clc20.appspot.com',
    iosBundleId: 'com.iotecksolutions.flutterBoilerplateProject.RunnerTests',
  );
}
