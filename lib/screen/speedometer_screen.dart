import 'package:ae86_speedometer/widgets/speedometer.dart';
import 'package:flutter/material.dart';
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

          return StreamBuilder(
              stream: (snapshot.data as Stream),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                var data = snapshot.data as LocationData;
                double speed = double.parse(
                    ((data.speed ?? 0) * 3.6).toStringAsFixed(2)
                );
                return Speedometer(speed: speed);
              });
        });
  }
}
