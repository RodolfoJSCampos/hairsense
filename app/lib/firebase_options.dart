
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: 'AIzaSyBpOfc11sktESaqeyo1KSLQGrDQGiYswnk',
    appId: '1:660846289918:web:747ec916f7b737e09fd6af',
    messagingSenderId: '660846289918',
    projectId: 'hairsenseapp',
    authDomain: 'hairsenseapp.firebaseapp.com',
    storageBucket: 'hairsenseapp.firebasestorage.app',
    measurementId: 'G-E8ZZFS7GSJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApyUPPwfBVKrVAZfFiGQajaWAZdUY_YLM',
    appId: '1:660846289918:android:25b040937dc372f19fd6af',
    messagingSenderId: '660846289918',
    projectId: 'hairsenseapp',
    storageBucket: 'hairsenseapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwWcUGPwaqwr0VVP_UF1GOLq4OHWbqePg',
    appId: '1:660846289918:ios:4970858fd8d314f49fd6af',
    messagingSenderId: '660846289918',
    projectId: 'hairsenseapp',
    storageBucket: 'hairsenseapp.firebasestorage.app',
    iosBundleId: 'com.example.tcc',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBwWcUGPwaqwr0VVP_UF1GOLq4OHWbqePg',
    appId: '1:660846289918:ios:4970858fd8d314f49fd6af',
    messagingSenderId: '660846289918',
    projectId: 'hairsenseapp',
    storageBucket: 'hairsenseapp.firebasestorage.app',
    iosBundleId: 'com.example.tcc',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpOfc11sktESaqeyo1KSLQGrDQGiYswnk',
    appId: '1:660846289918:web:aa2666c4f963b4df9fd6af',
    messagingSenderId: '660846289918',
    projectId: 'hairsenseapp',
    authDomain: 'hairsenseapp.firebaseapp.com',
    storageBucket: 'hairsenseapp.firebasestorage.app',
    measurementId: 'G-QMSKMSZ74D',
  );
}
