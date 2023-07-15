import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todolistapp/pages/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for Errors
          if (snapshot.hasError) {
            print("Something Went Wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return MaterialApp(
            title: 'To-Do app',
            theme: ThemeData(
              primarySwatch: Colors.red,
            ),
            debugShowCheckedModeBanner: false,
            home: Login(),
          );
        });
  }
}