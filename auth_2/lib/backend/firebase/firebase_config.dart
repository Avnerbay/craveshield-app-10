import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAx0hfJ_3tkGvvdahsx3sPk0hGfcXHEpaA",
            authDomain: "thenew-crave-shield-app-sen3wk.firebaseapp.com",
            projectId: "thenew-crave-shield-app-sen3wk",
            storageBucket: "thenew-crave-shield-app-sen3wk.firebasestorage.app",
            messagingSenderId: "702563587121",
            appId: "1:702563587121:web:a2dc0e6b6520213459f110"));
  } else {
    await Firebase.initializeApp();
  }
}
