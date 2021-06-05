import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class Speedometer extends StatelessWidget {
  final double speed;

  Speedometer({required this.speed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "$speed km/h",
        textAlign: TextAlign.center,
      ),
    );
  }
}
