import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions no están configuradas para web. '
        'Ejecuta `flutterfire configure` para generarlas.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'FirebaseOptions no están configuradas para $defaultTargetPlatform. '
          'Ejecuta `flutterfire configure` para generarlas.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyrLsnN8JZu0alyaqaiUFLmOnvbsNY4p8',
    appId: '1:135084387270:android:f5709dd94dcd8a3b9620c7',
    messagingSenderId: '135084387270',
    projectId: 'planificau-e491e',
    storageBucket: 'planificau-e491e.firebasestorage.app',
  );
}
