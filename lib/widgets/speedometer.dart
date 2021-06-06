import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ini/ini.dart';
import 'package:location/location.dart';

void _entrypoint() => AudioServiceBackground.run(() => PlayChimeBackgroundTask());

class Speedometer extends StatefulWidget {
  final Stream stream;

  Speedometer({required this.stream});

  @override
  _SpeedometerState createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  final String loadedTachometerTheme = 'D7';
  final double maxSpeed = 10;

  @override
  Widget build(BuildContext context) {
    // playChime();
    return FutureBuilder(
        future: loadSpeedometerConfig(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Ops... An error occurred');
          }

          Config tachometerConfig = (snapshot.data as Config);

          return speedometer(tachometerConfig, widget.stream);
        });
  }

  Widget showSpeed(double speed, Config tachometerConfig) {
    String roundedSpeed = (speed.toInt()).toString();
    List<Widget> widgets = [];
    double speedDigitWidth = double.parse(tachometerConfig.get('Speed', 'speed_width') ?? '0');
    double speedDigitHeight = double.parse(tachometerConfig.get('Speed', 'speed_height') ?? '0');
    double speedDigitY = double.parse(tachometerConfig.get('Speed', 'speed_y') ?? '0');
    double speedDigitX = double.parse(tachometerConfig.get('Speed', 'speed_x') ?? '0');

    for (int i = 0; i < roundedSpeed.length; i++) {
      widgets.add(
          Image.asset(
            "assets/tachometers/$loadedTachometerTheme/speed_yellow/speed_digits_${roundedSpeed[i]}.png",
            width: speedDigitWidth,
            height: speedDigitHeight,
          )
      );
    }


    return Positioned(
      child: Row(
        children: widgets,
      ),
      top: speedDigitY,
      left: speedDigitX - ((roundedSpeed.length - 1) * (speedDigitWidth)),
    );
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
        angle: 270 * (-(pi) / 180),
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: (rpmX) - rpmImageHeight,
          ),
          child: RotatedBox(
            quarterTurns: 1,
            child: Image.asset(
              "assets/tachometers/$loadedTachometerTheme/rpm_bar/rpm_bar.png",
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

  Future<Config> loadSpeedometerConfig() async {
    String configString =
    await rootBundle.loadString("assets/tachometers/$loadedTachometerTheme/theme_config.ini");
    return Config.fromString(configString);
  }

  Widget speedometer(Config tachometerConfig, Stream stream) {
    return Container(
      child: Column(
        children: [
          StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Caricando...');
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                var data = snapshot.data as LocationData;
                double speed = double.parse(((data.speed ?? 0) * 3.6).toStringAsFixed(2));
                return Text(
                  "$speed km/h",
                  textAlign: TextAlign.center,
                );
              }),
          Center(
            child: Stack(
              children: [
                // Tachometer background
                Image.asset(
                  "assets/tachometers/$loadedTachometerTheme/background/background.png",
                  width:
                  double.parse(tachometerConfig.get('Background', 'background_width') ?? '0'),
                  height:
                  double.parse(tachometerConfig.get('Background', 'background_height') ?? '0'),
                ),
                // Unità di misura (km/h)
                Positioned(
                  child: Image.asset("assets/tachometers/$loadedTachometerTheme/speed_unit/kmh.png",
                      width: double.parse(tachometerConfig.get('Speed Unit', 'unit_width') ?? '0'),
                      height:
                      double.parse(tachometerConfig.get('Speed Unit', 'unit_height') ?? '0')),
                  top: double.parse(tachometerConfig.get('Speed Unit', 'unit_y') ?? '0'),
                  left: double.parse(tachometerConfig.get('Speed Unit', 'unit_x') ?? '0'),
                ),
                // Codice per visualizzare la freccia del tachimetro
                // Etichette degli RPM
                Positioned(
                  child: Image.asset(
                    "assets/tachometers/$loadedTachometerTheme/background/labels_20k.png",
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return showSpeed(0, tachometerConfig);
                      }

                      if (snapshot.hasError) {
                        return showSpeed(0, tachometerConfig);
                      }

                      var data = snapshot.data as LocationData;
                      double speed = double.parse(((data.speed ?? 0) * 3.6).toStringAsFixed(2));
                      return showSpeed(speed, tachometerConfig);
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
