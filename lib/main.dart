import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/screens/index_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCUwXlR-ZsmAzW6bp2gVldYYWplxTfWCsA",
          projectId: "flutter-to-do-8bba1",
          messagingSenderId: "218885375290",
          storageBucket: "flutter-to-do-8bba1.appspot.com",
          appId: "1:218885375290:web:39c372d83de36a4b6ffc03"));

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: IndexScreen(),
    );
  }
}
