import 'dart:math';
import 'package:ae86_speedometer/utils/speed_utils.dart';
import 'package:ae86_speedometer/widgets/speedometer_speed_digits.dart';
import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:location/location.dart';

void _entrypoint() => AudioServiceBackground.run(() => PlayChimeBackgroundTask());

class Speedometer extends StatefulWidget {
  final Stream stream;
  final Config tachometerConfig;
  final String theme;
  final String speedUnit;

  Speedometer({
    required this.stream,
    required this.tachometerConfig,
    required this.theme,
    required this.speedUnit,
  });

  @override
  _SpeedometerState createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  final double maxSpeed = 10;

  @override
  Widget build(BuildContext context) {
    // playChime();
    return speedometer(widget.tachometerConfig, widget.stream);
  }

  Widget showSpeedIndicator(Config tachometerConfig) {
    double rpmCenterX = double.parse(tachometerConfig.get('RPM Bar', 'rpm_center_x') ?? '0');
    double rpmCenterY = double.parse(tachometerConfig.get('RPM Bar', 'rpm_center_y') ?? '0');
    double rpmX = double.parse(tachometerConfig.get('RPM Bar', 'rpm_x') ?? '0');
    double rpmY = double.parse(tachometerConfig.get('RPM Bar', 'rpm_y') ?? '0');
    double rpmImageWidth = double.parse(tachometerConfig.get('RPM Bar', 'rpm_width') ?? '0');
    double rpmImageHeight = double.parse(tachometerConfig.get('RPM Bar', 'rpm_height') ?? '0');

    // Posiziono al centro dello schermo l'indicatore della velocità
    return Positioned(
      left: rpmCenterX,
      top: rpmCenterY - rpmY,
      child: Transform.rotate(
        angle: 90 * ((pi) / 180),
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: (rpmX) - rpmImageHeight,
          ),
          child: RotatedBox(
            quarterTurns: 1,
            child: Image.asset(
              "assets/tachometers/${widget.theme}/rpm_bar/rpm_bar.png",
              width: rpmImageWidth,
              height: rpmImageHeight,
            ),
          ),
        ),
      ),
    );
  }

  /*
    void playChime() async {
      AudioService.connect();

      if (widget.speed >= maxSpeed && !AudioService.running) {
        await AudioService.start(backgroundTaskEntrypoint: _entrypoint);
        return;
      }

      if (widget.speed >= maxSpeed) {
        await AudioService.play();
        return;
      }

      if (widget.speed < maxSpeed && AudioService.running) {
        await AudioService.stop();
      }
    }
  */

  Widget speedometer(Config tachometerConfig, Stream stream) {
    String loadedTheme = widget.theme;
    String speedUnit = widget.speedUnit;

    return Container(
      child: Column(
        children: [
          StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                double speed = 0;

                if (snapshot.data != null) {
                  var data = snapshot.data as LocationData;
                  speed = data.speed ?? 0;
                }

                if (speedUnit == 'mph') {
                  speed = SpeedUtils.toMph(speed);
                }
                return Text(
                  "${SpeedUtils.getIntVal(speed)} $speedUnit",
                  textAlign: TextAlign.center,
                );
              }),
          Center(
            child: Stack(
              children: [
                // Tachometer background
                Image.asset(
                  "assets/tachometers/${widget.theme}/background/background.png",
                  width:
                      double.parse(tachometerConfig.get('Background', 'background_width') ?? '0'),
                  height:
                      double.parse(tachometerConfig.get('Background', 'background_height') ?? '0'),
                ),
                // Unità di misura (km/h)
                Positioned(
                  child: Image.asset("assets/tachometers/$loadedTheme/speed_unit/$speedUnit.png",
                      width: double.parse(tachometerConfig.get('Speed Unit', 'unit_width') ?? '0'),
                      height:
                          double.parse(tachometerConfig.get('Speed Unit', 'unit_height') ?? '0')),
                  top: double.parse(tachometerConfig.get('Speed Unit', 'unit_y') ?? '0'),
                  left: double.parse(tachometerConfig.get('Speed Unit', 'unit_x') ?? '0'),
                ),
                // Etichette degli RPM
                Positioned(
                  child: Image.asset(
                    "assets/tachometers/$loadedTheme/background/labels_20k.png",
                    width: double.parse(tachometerConfig.get('RPM Gauge', 'gauge_width') ?? '0'),
                    height: double.parse(tachometerConfig.get('RPM Gauge', 'gauge_height') ?? '0'),
                  ),
                  top: double.parse(tachometerConfig.get('RPM Gauge', 'gauge_y') ?? '0'),
                  left: double.parse(tachometerConfig.get('RPM Gauge', 'gauge_x') ?? '0'),
                ),
                // Velocità in Km/h
                StreamBuilder(
                    stream: widget.stream,
                    builder: (context, snapshot) {
                      double speedDigitWidth =
                          double.parse(tachometerConfig.get('Speed', 'speed_width') ?? '0');
                      double speedDigitHeight =
                          double.parse(tachometerConfig.get('Speed', 'speed_height') ?? '0');
                      double speedDigitY =
                          double.parse(tachometerConfig.get('Speed', 'speed_y') ?? '0');
                      double speedDigitX =
                          double.parse(tachometerConfig.get('Speed', 'speed_x') ?? '0');

                      double speed = 0;

                      if (snapshot.data != null) {
                        var data = snapshot.data as LocationData;
                        speed = data.speed ?? 0;
                      }

                      if (speedUnit == 'mph') {
                        speed = SpeedUtils.toMph(speed);
                      }

                      return SpeedometerSpeedDigits(
                          speed: SpeedUtils.getIntVal(speed),
                          speedDigitWidth: speedDigitWidth,
                          speedDigitHeight: speedDigitHeight,
                          speedDigitX: speedDigitX,
                          speedDigitY: speedDigitY,
                          theme: widget.theme
                      );
                    }),
                // TOOD: cercare di capire come aggiungere la lancetta basata sui Km/h
                showSpeedIndicator(tachometerConfig),
              ],
            ),
          )
        ],
      ),
    );
  }
}
