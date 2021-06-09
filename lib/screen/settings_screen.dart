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
  String _theme = '';


  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    Box box = Hive.box('app');
    _speedUnit = box.get('speed_unit', defaultValue: 'kmh');
    _theme = box.get('theme', defaultValue: 'D7');
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
                              setState(() =>_speedUnit = value ?? '');
                            },
                          ),
                          Text('Mp/h')
                        ],
                      )
                    ])
                  ],
                ),
                // Theme
                Column(
                  children: [
                    Text('Theme:'),
                    FutureBuilder(
                        future: loadThemesList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          if (snapshot.data == null) {
                            return Center(
                               child: CircularProgressIndicator(),
                            );
                          }

                          var dirs = (snapshot.data as List<String>);

                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                                itemCount: dirs.length,
                                itemBuilder: (_, index) {
                                  return ListTile(
                                    leading: Radio(
                                      groupValue: _theme,
                                      value: dirs[index],
                                      onChanged: (String? value) async {
                                        await Hive.box('app').put('theme', value);
                                        setState(() => _theme = value ?? '');
                                      },
                                    ),
                                    title: Text(dirs[index]),
                                  );
                                }
                            ),
                          );
                        },
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  Future<List<String>> loadThemesList() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    var re = RegExp(r'(?<=assets/tachometers/)(D[\d])(?=/)');

    return manifestMap.keys
        .where((String key) => re.hasMatch(key))
        .map((String key) {
          return re.stringMatch(key) ?? '';
        })
        .toSet()
        .toList();
  }
}
