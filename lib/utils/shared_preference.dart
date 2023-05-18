import 'dart:convert';


import '/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Preference {
  static final Preference _instance = Preference._internal();
  SharedPreferences? _prefs;

  factory Preference.instance() {
    return _instance;
  }

  Preference._internal() {
    _init();
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Last GPS location
  set lastLocation(List<double>? latlng) {
    if (latlng != null) {
      _prefs?.setDouble('last_lat', latlng[0]);
      _prefs?.setDouble('last_lng', latlng[1]);
    }
  }

  List<double>? get lastLocation {
    if (_prefs?.getDouble('last_lat') == null || _prefs?.getDouble('last_lng') == null) {
      return null;
    } else {
      return <double>[_prefs!.getDouble('last_lat')!, _prefs!.getDouble('last_lng')!];
    }
  }

  /// The location when ble is disconnected
  setDisconnectLocation(List<double>? latlng, int timestamp){
    if (latlng != null) {
      _prefs?.setDouble('disconnect_lat', latlng[0]);
      _prefs?.setDouble('disconnect_lng', latlng[1]);
      _prefs?.setInt('disconnect_timestamp', timestamp);
    }
  }

  List<dynamic>? get disconnectLocation {
    if (_prefs?.getDouble('disconnect_lat') == null || _prefs?.getDouble('disconnect_lng') == null) {
      return null;
    } else {
      return [_prefs!.getDouble('disconnect_lat')!, _prefs!.getDouble('disconnect_lng')!, _prefs!.getInt('disconnect_timestamp')!];
    }
  }

  // Settings
  putDistanceUnit(DistanceUnit unit) {
    _prefs?.setString('distanceUnit', unit.name);
  }

  DistanceUnit getDistanceUnit() {
    String unit = _prefs?.getString('distanceUnit') ?? DistanceUnit.metric.name;
    return DistanceUnit.getUnitByString(unit);
  }

  putTemperatureUnit(TemperatureUnit unit) {
    _prefs?.setString('temperatureUnit', unit.name);
  }

  TemperatureUnit getTemperatureUnit() {
    String unit = _prefs?.getString('temperatureUnit') ?? TemperatureUnit.celsius.name;
    return TemperatureUnit.getUnitByString(unit);
  }

  putAvoidTolls(bool avoid){
    _prefs?.setBool('avoidtolls', avoid);
  }

  bool avoidTolls(){
    return _prefs?.getBool('avoidtolls') ?? true;
  }

  putAvoidHighway(bool avoid){
    _prefs?.setBool('avoidhighway', avoid);
  }

  bool avoidHighway(){
    return _prefs?.getBool('avoidhighway') ?? true;
  }

  putAllowNaviSpeach(bool enable){
    _prefs?.setBool('enablespeach',  enable);
  }

  bool allowNaviSpeach(){
    return _prefs?.getBool('enablespeach') ?? true;
  }



  void putLastConnectAddress(String address) {
    _prefs?.setString('lastConnectAddress', address);
  }

  String? getLastConnectAddress() => _prefs?.getString('lastConnectAddress');


}
