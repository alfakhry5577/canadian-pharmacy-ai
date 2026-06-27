// GENERATED PLACEHOLDER — replace by running, from the mobile/ directory:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<your-firebase-project-id>
//
// That command overwrites this exact file with real values for your Firebase
// project and registers the Android app (com.roshetta.pharmacy) automatically,
// including dropping `android/app/google-services.json` in place.
//
// The placeholder values below are NOT functional — Firebase Messaging will
// fail to initialize until this file is regenerated.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'roshetta-ai-REPLACE',
    storageBucket: 'roshetta-ai-REPLACE.appspot.com',
  );
}
