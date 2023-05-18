import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const PREFERENCE_LASTCMD_INCOMINGINFO1 = 'PREFERENCE_LASTCMD_INCOMINGINFO1';
const PREFERENCE_LASTCMD_INCOMINGINFO2 = 'PREFERENCE_LASTCMD_INCOMINGINFO2';

enum DistanceUnit {
  metric,
  imperial;

  static DistanceUnit getUnitByString(String text) {
    if (text == 'metric') {
      return DistanceUnit.metric;
    } else {
      return DistanceUnit.imperial;
    }
  }
}

enum TemperatureUnit {
  celsius('metric'),
  fahrenheit('imperial');

  const TemperatureUnit(this.weatherApiValue);
  final String weatherApiValue;
  static TemperatureUnit getUnitByString(String text) {
    if (text == 'celsius') {
      return TemperatureUnit.celsius;
    } else {
      return TemperatureUnit.fahrenheit;
    }
  }
}



