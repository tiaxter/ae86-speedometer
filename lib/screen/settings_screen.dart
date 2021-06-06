import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen() : super();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _speedUnit = 'kmh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Oops...An error occurred');
          }

          SharedPreferences prefs = (snapshot.data as SharedPreferences);

          _speedUnit = prefs.getString('speed_unit') ?? 'kmh';

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16
              ),
              child: Column(
                children: [
                  // Speed unit
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Speed unit:',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Row(children: [
                        // Km/h
                        Row(
                          children: [
                            Radio(
                              value: 'kmh',
                              groupValue: _speedUnit,
                              onChanged: (String? value) async {
                                setState(() {
                                  _speedUnit = value ?? '';
                                });
                                await prefs.setString('speed_unit', value ?? 'kmh');
                              },
                            ),
                            Text('Km/h')
                          ],
                        ),
                        // Mp/h
                        Row(
                          children: [
                            Radio(
                              value: 'mph',
                              groupValue: _speedUnit,
                              onChanged: (String? value) async {
                                setState(() {
                                  _speedUnit = value ?? '';
                                });
                                await prefs.setString('speed_unit', value ?? 'mph');
                              },
                            ),
                            Text('Mp/h')
                          ],
                        )
                      ])
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
