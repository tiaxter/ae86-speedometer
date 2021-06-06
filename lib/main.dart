import 'package:ae86_speedometer/screen/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AE86 Speedometer',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainScreen()
    );
  }
}
