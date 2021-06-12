import 'package:ae86_speedometer/utils/speed_utils.dart';
import 'package:ae86_speedometer/widgets/ae86_tachometer_background.dart';
import 'package:ae86_speedometer/widgets/speedometer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';

void _entrypoint() => AudioServiceBackground.run(() => PlayChimeBackgroundTask());

class SpeedometerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SpeedUtils.determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          Stream stream = snapshot.data as Stream;

          subscribeToStream(stream);

          return Speedometer(
            stream: stream,
          );
        });
  }

  void subscribeToStream(Stream stream) {
    stream.listen((event) {
      playChime(event);

      Hive.box('app').listenable(keys: ['chime_enabled', 'chime_speed_trigger']).addListener(() {
        playChime(event);
      });
    });
  }

  void playChime (event) async {
    if (!Hive.box('app').get('chime_enabled', defaultValue: false)) {
      return;
    }

    double speed = SpeedUtils.fromMSecondToKmHour(event.speed);
    double maxSpeed = Hive.box('app').get('chime_speed_trigger', defaultValue: 0.0);
    AudioService.connect();

    if (speed >= maxSpeed && !AudioService.running) {
      await AudioService.start(backgroundTaskEntrypoint: _entrypoint);
      return;
    }

    if (speed >= maxSpeed) {
      await AudioService.play();
      return;
    }

    if (speed < maxSpeed && AudioService.running) {
      await AudioService.pause();
    }
  }
}
