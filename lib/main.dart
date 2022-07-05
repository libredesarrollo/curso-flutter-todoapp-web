import 'package:flutter/material.dart';
import 'package:todoapp/screens/index_screen.dart';

void main() => runApp(MyApp());

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
