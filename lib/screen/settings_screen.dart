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
  String? _speedDigitsTheme;
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
    _speedDigitsTheme = box.get('speed_digits_theme', defaultValue: null);
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

                        return DropdownButton<String>(
                            isExpanded: true,
                            isDense: true,
                            value: _theme,
                            items: dirs
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? value) async {
                              if (value == null) {
                                return;
                              }
                              Hive.box('app').put('theme', value);
                              setState(() => _theme = value);
                            });
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    Text('Speed digits theme'),
                    FutureBuilder(
                      future: loadSpeedDigitsTheme(_theme),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Text('Loading...');
                        }

                        // Lista dei temi delle cifre della velocità
                        List<String> speedDigitsThemes = (snapshot.data as List<String>);

                        // Se il tema nello stato non è contenuto nei temi del tema del tachimetro
                        if (!speedDigitsThemes.contains(_speedDigitsTheme)) {
                          // Allora imposto come tema delle cifre il primo disponibile
                          _speedDigitsTheme = speedDigitsThemes.first;
                          Hive.box('app').put('speed_digits_theme', _speedDigitsTheme);
                        }

                        return DropdownButton(
                          isExpanded: true,
                          isDense: true,
                          value: _speedDigitsTheme,
                          items: speedDigitsThemes
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            Hive.box('app').put('speed_digits_theme', value);
                            setState(() => _speedDigitsTheme = value);
                          },
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Future<List<String>> loadThemesList() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    var re = RegExp(r'(?<=assets/tachometers/)(D[\d])(?=/)');

    return manifestMap.keys
        .where((String key) => re.hasMatch(key))
        .map((String key) => re.stringMatch(key) ?? '')
        .toSet()
        .toList();
  }

  Future<List<String>> loadSpeedDigitsTheme([String? theme]) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return manifestMap.keys
        .where((String key) =>
            key.contains('assets/tachometers/${theme ?? _theme}/speed_') && !key.contains('speed_unit'))
        .map((String key) {
          final startString = 'assets/tachometers/${theme ?? _theme}/';
          final startIndex = key.indexOf(startString);
          final endIndex = key.indexOf('/', startIndex + startString.length);

          return key.substring(
              startIndex + startString.length, endIndex
          ).trim();
        })
        .toSet()
        .toList();
  }
}
