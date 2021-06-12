import 'package:ae86_speedometer/utils/speed_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

import 'ae86_tachometer_background.dart';

class Speedometer extends StatelessWidget {
  final Stream stream;

  Speedometer({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(builder: (BuildContext context, snapshot) {
      double speed = 0;

      if (snapshot.data != null) {
        var data = snapshot.data as LocationData;
        speed = SpeedUtils.fromMSecondToKmHour(data.speed ?? 0);
      }

      return Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: Ae86TachometerBackground(speed.toInt()),
          ),
        ),
      );
    });
  }

}
