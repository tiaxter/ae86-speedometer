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
        backgroundColor: Color.fromRGBO(67, 67, 67, 1.0),
        appBar: AppBar(
          title: Text('AE86 Speedometer'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
              icon: Icon(Icons.settings),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Box box = Hive.box('app');
            String chimeEnabledKey = 'chime_enabled';

            if (box.get(chimeEnabledKey, defaultValue: true)) {
              box.put(chimeEnabledKey, false);
              AudioService.connect();
              await AudioService.pause();
              return;
            }

            box.put(chimeEnabledKey, true);
          },
          child: ValueListenableBuilder(
              valueListenable: Hive.box('app').listenable(keys: ['chime_enabled']),
              builder: (context, Box box, snapshot) {
                String chimeEnabledKey = 'chime_enabled';

                if (box.get(chimeEnabledKey, defaultValue: true)) {
                  return Icon(Icons.pause);
                }

                return Icon(Icons.play_arrow);
              }),
        ),
        body: SpeedometerScreen());
  }
}
