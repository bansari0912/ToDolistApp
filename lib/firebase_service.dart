import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static FirebaseFirestore getFirestore() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore;
  }
}


