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
    apiKey: 'AIzaSyAzw5WeAHOXEiAo3HXYVBFI6kQ5qWQ15T4',
    appId: '1:389003797572:web:d10b0c3c81486042adc811',
    messagingSenderId: '389003797572',
    projectId: 'registrousuarios-9c9b2',
    authDomain: 'registrousuarios-9c9b2.firebaseapp.com',
    storageBucket: 'registrousuarios-9c9b2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9rs0JKpkd00jwd6RtWAuI2nkK76P_P0s',
    appId: '1:389003797572:android:9d58db48019f4749adc811',
    messagingSenderId: '389003797572',
    projectId: 'registrousuarios-9c9b2',
    storageBucket: 'registrousuarios-9c9b2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBNY7dWyQYp-ohKiwFnmPA7QTE17z0Prs',
    appId: '1:389003797572:ios:00d95c537780a293adc811',
    messagingSenderId: '389003797572',
    projectId: 'registrousuarios-9c9b2',
    storageBucket: 'registrousuarios-9c9b2.firebasestorage.app',
    iosBundleId: 'com.example.t4bd',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBBNY7dWyQYp-ohKiwFnmPA7QTE17z0Prs',
    appId: '1:389003797572:ios:00d95c537780a293adc811',
    messagingSenderId: '389003797572',
    projectId: 'registrousuarios-9c9b2',
    storageBucket: 'registrousuarios-9c9b2.firebasestorage.app',
    iosBundleId: 'com.example.t4bd',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAzw5WeAHOXEiAo3HXYVBFI6kQ5qWQ15T4',
    appId: '1:389003797572:web:bbbf27d905bf1ff4adc811',
    messagingSenderId: '389003797572',
    projectId: 'registrousuarios-9c9b2',
    authDomain: 'registrousuarios-9c9b2.firebaseapp.com',
    storageBucket: 'registrousuarios-9c9b2.firebasestorage.app',
  );

}