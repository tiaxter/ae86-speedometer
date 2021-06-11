import 'package:ae86_speedometer/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('app');
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
        home: MainScreen());
  }
}
