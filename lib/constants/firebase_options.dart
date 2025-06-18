import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for web in this build.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBMQZ0MixjoqE_HPDLWCdV4Wd2k6elUso4',
    appId: '1:229483261465:web:40ff43ba0e7a0197700488',
    messagingSenderId: '229483261465',
    projectId: 'polar-14343',
    authDomain: 'polar-14343.firebaseapp.com',
    storageBucket: 'polar-14343.firebasestorage.app',
    measurementId: 'G-10XSPGGSB8',
  );
}
