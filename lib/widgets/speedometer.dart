import 'package:flutter/services.dart' show rootBundle;
import 'package:ae86_speedometer/tasks/play_chime_background_task.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ini/ini.dart';

void _entrypoint() =>
    AudioServiceBackground.run(() => PlayChimeBackgroundTask());

class Speedometer extends StatefulWidget {
  final double speed;

  Speedometer({required this.speed});

  @override
  _SpeedometerState createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  final String loadedTachometerTheme = 'D7';
  final double maxSpeed = 10;
  late Config tachometerConfig;

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    playChime();
    return Container(
      child: Column(
        children: [
          Text(
            "${widget.speed} km/h",
            textAlign: TextAlign.center,
          ),
          Center(
            child: Stack(
              children: [
                // Tachometer background
                Image.asset(
                  "assets/tachometers/$loadedTachometerTheme/background/background.png",
                  width: double.parse(
                      tachometerConfig.get('Background', 'background_width') ??
                          '0'),
                  height: double.parse(
                      tachometerConfig.get('Background', 'background_height') ??
                          '0'),
                ),
                // Unità di misura (km/h)
                Positioned(
                  child: Image.asset(
                      "assets/tachometers/$loadedTachometerTheme/speed_unit/kmh.png",
                      width: double.parse(
                          tachometerConfig.get('Speed Unit', 'unit_width') ??
                              '0'),
                      height: double.parse(
                          tachometerConfig.get('Speed Unit', 'unit_height') ??
                              '0')),
                  top: double.parse(
                      tachometerConfig.get('Speed Unit', 'unit_y') ?? '0'),
                  left: double.parse(
                      tachometerConfig.get('Speed Unit', 'unit_x') ?? '0'),
                ),
                // Etichette degli RPM
                Positioned(
                  child: Image.asset(
                    "assets/tachometers/$loadedTachometerTheme/background/labels_20k.png",
                    width: double.parse(
                        tachometerConfig.get('RPM Gauge', 'gauge_width') ?? '0'),
                    height: double.parse(
                        tachometerConfig.get('RPM Gauge', 'gauge_height') ?? '0'),
                  ),
                  top: double.parse(
                      tachometerConfig.get('RPM Gauge', 'gauge_y') ?? '0'),
                  left: double.parse(
                      tachometerConfig.get('RPM Gauge', 'gauge_x') ?? '0'),
                ),
                // Velocità in Km/h
                ...showSpeed(widget.speed)
                // TOOD: cercare di capire come aggiungere la lancetta basata sui Km/h
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> showSpeed(double speed) {
    String roundedSpeed = (speed.toInt()).toString();
    List<Widget> widgets = [];

    for (int i = 0; i < roundedSpeed.length; i++) {
      widgets.add(
        Positioned(
            child: Image.asset(
              "assets/tachometers/$loadedTachometerTheme/speed_yellow/speed_digits_${roundedSpeed[i]}.png",
              width: double.parse(
                tachometerConfig.get('Speed', 'speed_width') ?? '0'
              ),
              height: double.parse(
                  tachometerConfig.get('Speed', 'speed_height') ?? '0'
              ),
            ),
            top: double.parse(
                tachometerConfig.get('Speed', 'speed_y') ?? '0'
            ),
            // x - (width * i)
            left: double.parse(
                tachometerConfig.get('Speed', 'speed_x') ?? '0'
            ) - (
                double.parse(
                    tachometerConfig.get('Speed', 'speed_width') ?? '0'
                ) * (roundedSpeed.length - (i + 1))
            )
        )
      );
    }

    return widgets;
  }

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

  void setup() async {
    Config config = await loadSpeedometerConfig();
    setState(() {
      tachometerConfig = config;
    });
  }

  Future<Config> loadSpeedometerConfig() async {
    String configString = await rootBundle.loadString(
        "assets/tachometers/$loadedTachometerTheme/theme_config.ini");
    print(configString);
    return Config.fromString(configString);
  }
}
