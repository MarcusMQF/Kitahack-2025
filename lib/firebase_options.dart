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
    apiKey: 'AIzaSyDb-apWLOGCvaGJWPFcQ0M4fXKR45DpZDA',
    appId: '1:342074446418:web:fdec83110bbcb94668058b',
    messagingSenderId: '342074446418',
    projectId: 'transitgo-7017c',
    authDomain: 'transitgo-7017c.firebaseapp.com',
    storageBucket: 'transitgo-7017c.firebasestorage.app',
    measurementId: 'G-YL3WFY039R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCms4abTLxa0DpPP00cLPOpCE_zLEfrnRU',
    appId: '1:342074446418:android:25ce76f18b53a83568058b',
    messagingSenderId: '342074446418',
    projectId: 'transitgo-7017c',
    storageBucket: 'transitgo-7017c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDz9OXzcOTq3kZF33uTW4D_YQa1YpjpV8Q',
    appId: '1:342074446418:ios:5c24b5b5cb3bf67e68058b',
    messagingSenderId: '342074446418',
    projectId: 'transitgo-7017c',
    storageBucket: 'transitgo-7017c.firebasestorage.app',
    iosBundleId: 'com.transitgo.transit_go_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDz9OXzcOTq3kZF33uTW4D_YQa1YpjpV8Q',
    appId: '1:342074446418:ios:5c24b5b5cb3bf67e68058b',
    messagingSenderId: '342074446418',
    projectId: 'transitgo-7017c',
    storageBucket: 'transitgo-7017c.firebasestorage.app',
    iosBundleId: 'com.transitgo.transit_go_app',
  );
}
