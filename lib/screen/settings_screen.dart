import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _speedUnit = '';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    Box box = Hive.box('app');
    _speedUnit = box.get('speed_unit', defaultValue: 'kmh');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              await Hive.box('app').put('speed_unit', value);
                              setState(() => _speedUnit = value ?? '');
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
                              await Hive.box('app').put('speed_unit', value);
                              setState(() => _speedUnit = value ?? '');
                            },
                          ),
                          Text('Mp/h')
                        ],
                      )
                    ])
                  ],
                ),
                // Speed chime trigger
                Column(
                  children: [
                    Text('Speed chime trigger'),
                    TextFormField(
                      initialValue: Hive.box('app').get('chime_speed_trigger', defaultValue: 0).toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter speed chime trigger',
                      ),
                      onChanged: (String value) {
                        if (value.isEmpty) {
                          value = '0';
                        }
                        double val = double.parse(value);
                        Hive.box('app').put('chime_speed_trigger', val);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
