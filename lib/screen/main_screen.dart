import 'package:ae86_speedometer/screen/settings_screen.dart';
import 'package:ae86_speedometer/screen/speedometer_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AE86 Speedometer'),
          actions: [
            ValueListenableBuilder(
                valueListenable: Hive.box('app').listenable(keys: ['chime_enabled']),
                builder: (context, Box box, snapshot) {
                  if (box.get('chime_enabled', defaultValue: true)) {
                    return IconButton(
                        onPressed: () async {
                          box.put('chime_enabled', false);
                          AudioService.connect();
                          await AudioService.pause();
                        },
                        icon: Icon(Icons.pause));
                  }

                  return IconButton(
                      onPressed: () {
                        box.put('chime_enabled', true);
                      },
                      icon: Icon(Icons.play_arrow));
                }),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
              icon: Icon(Icons.app_settings_alt),
            )
          ],
        ),
        body: SpeedometerScreen());
  }
}
