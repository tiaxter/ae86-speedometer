import 'package:ae86_speedometer/screen/settings_screen.dart';
import 'package:ae86_speedometer/screen/speedometer_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AE86 Speedometer'),
          actions: [
            Padding(
              padding: EdgeInsets.all(8),
              child: GestureDetector(
                  child: Icon(Icons.app_settings_alt),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return SettingsScreen();

                    }));
                  }),
            )
          ],
        ),
        body: SpeedometerScreen());
  }
}
