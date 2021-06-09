import 'package:ae86_speedometer/widgets/speedometer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ini/ini.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';

class SpeedometerScreen extends StatelessWidget {
  Future<Stream> _determinePosition() async {
    bool serviceEnabled;
    PermissionStatus permission;

    Location location = new Location();

    // Imposto l'accuratezza del GPS alta
    location.changeSettings(
        accuracy: LocationAccuracy.navigation, distanceFilter: 10);

    // Verifico se il servizio è abilitato
    serviceEnabled = await location.serviceEnabled();
    // Se non è abilitato richiedo all'utente di abilitarlo
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    // Se non è abilitato allora lancio un errore
    if (!serviceEnabled) {
      return Future.error('The service cannot be enabled');
    }

    // Verifico che all'applicazione sia permesso di utilizzare il GPS
    permission = await location.hasPermission();
    // Se il permesso è negato allora chiedo all'utente il permesso
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    // Se il permesso è negato per sempre allora lancio un errore
    if (permission == PermissionStatus.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Altrimenti restituisco lo stream al quale mi iscriverò per ricevere i vari
    // valore
    return location.onLocationChanged;
  }

  Future<Config> _loadTachometerConfig(String theme) async {
    String configString = await rootBundle.loadString("assets/tachometers/$theme/theme_config.ini");
    return Config.fromString(configString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          Stream stream = snapshot.data as Stream;
          return ValueListenableBuilder(
            valueListenable: Hive.box('app').listenable(),
            builder: (context, Box box, widget) {
              String theme = box.get('theme', defaultValue: 'D7');
              String speedUnit = box.get('speed_unit', defaultValue: 'kmh');

              return FutureBuilder(
                future: _loadTachometerConfig(theme),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Text('Loading...');
                  }

                  return Speedometer(
                    stream: stream,
                    tachometerConfig: (snapshot.data as Config),
                    theme: theme,
                    speedUnit: speedUnit,
                  );
                },
              );
            },
          );
        });
  }
}
