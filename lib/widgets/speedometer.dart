import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

void _entrypoint() =>
    AudioServiceBackground.run(() => PlayChimeBackgroundTask());

class Speedometer extends StatelessWidget {
  final double maxSpeed = 10;
  final double speed;

  Speedometer({required this.speed});

  @override
  Widget build(BuildContext context) {
    playChime();
    return Container(
      child: Text(
        "$speed km/h",
        textAlign: TextAlign.center,
      ),
    );
  }

  void playChime() async {
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
      await AudioService.stop();
    }
  }
}
