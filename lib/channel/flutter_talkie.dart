import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import '/manager/connect_manager.dart';
import '/rx5/base_incoming.dart';
import '/rx5/incoming_info1.dart';
import '/rx5/incoming_info2.dart';
import '/rx5/naviinfo.dart';
import '/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterTalkie talkie = FlutterTalkie();

class FlutterTalkie {
  static const platform = MethodChannel('com.koso.klink/bt');

  // incoming stream
  final StreamController<BaseIncoming> _incomingController = StreamController.broadcast();

  StreamSink<BaseIncoming> get _incomingSink => _incomingController.sink;

  Stream<BaseIncoming> get incomingStream => _incomingController.stream;

  // error stream
  final StreamController<String> _errorController = StreamController.broadcast();

  StreamSink<String> get _errorSink => _errorController.sink;

  Stream<String> get _errorStream => _errorController.stream;

  // candidates (scan results) stream
  final StreamController<List<dynamic>> _candidatesController = StreamController.broadcast();

  StreamSink<List<dynamic>> get _candidatesSink => _candidatesController.sink;

  Stream<List<dynamic>> get candidatesStream => _candidatesController.stream;

  FlutterTalkie() {
    initPreference();
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'scanresult':
          var candidates = call.arguments;
          _candidatesSink.add(candidates);
          break;
        case 'state':
          connectManager.state = getConnectStateFromString(call.arguments);
          break;
        case 'incominginfo1':
          var json = call.arguments;
          Map<String, dynamic> map = jsonDecode(json);
          var cmd = IncomingInfo1.fromJson(map);
          _incomingSink.add(cmd);
          keepLastIncomingInfo1(json);
          break;
        case 'incominginfo2':
          var json = call.arguments;
          Map<String, dynamic> map = jsonDecode(json);
          var cmd = IncomingInfo2.fromJson(map);
          _incomingSink.add(cmd);
          keepLastIncomingInfo2(json);
          break;
        case 'error':
          _errorSink.add(call.arguments);
          break;
      }
    });
  }

  Future<String> sendWhatState() async => await platform.invokeMethod('whatstate', null);

  Future sendStartForeground() => platform.invokeMethod('startforeground', null);

  Future sendScan() => platform.invokeMethod('scan', null);

  Future sendLeScan() => platform.invokeMethod('lescan');

  Future sendStopScan() => platform.invokeMethod('stopscan', null);

  Future sendConnect(String address) => platform.invokeMethod('connect', <String, dynamic>{
        'address': address,
      });

  Future sendLeConnect(String address) => platform.invokeMethod('leconnect', <String, dynamic>{
    'address': address,
  });

  Future sendEnd() => platform.invokeMethod('disconnect', null);

  Future sendNaviInfo(NaviInfo cmd) {
    var j = json.encode(cmd);
    return platform.invokeMethod('naviinfo', <String, dynamic>{
      'naviinfo': j,
    });
  }

  Future startAncs() => platform.invokeMethod('start_ancs');


  /**
   * To update text message on notification
   */
  Future sendNaviNotify(String msg) => platform.invokeMethod('update_navinotify', <String, dynamic>{
    'msg': msg,
  });


  Future sendDismissNaviNotify() => platform.invokeMethod('dismiss_navinotify');

  SharedPreferences? _prefs = null;
  void initPreference() async{
    // Obtain shared preferences.
    _prefs = await SharedPreferences.getInstance();
    var info2 = _prefs!.getString(PREFERENCE_LASTCMD_INCOMINGINFO2);

    if(info2 != null) {
      Map<String, dynamic> map = jsonDecode(info2);
      var cmd = IncomingInfo2.fromJson(map);
      _incomingSink.add(cmd);
    }
  }

  void keepLastIncomingInfo1(String json) async{
    await _prefs?.setString(PREFERENCE_LASTCMD_INCOMINGINFO1, json);
  }

  void keepLastIncomingInfo2(String json) async{
    await _prefs?.setString(PREFERENCE_LASTCMD_INCOMINGINFO2, json);
  }

  Future<IncomingInfo1?> getLastInfo1() async {
    _prefs = await SharedPreferences.getInstance();
    var info1 = _prefs!.getString(PREFERENCE_LASTCMD_INCOMINGINFO1);

    if(info1 != null) {
      Map<String, dynamic> map = jsonDecode(info1);
      var cmd = IncomingInfo1.fromJson(map);
      return cmd;
    }
    return null;
  }

  Future<IncomingInfo2?> getLastInfo2() async {
    _prefs = await SharedPreferences.getInstance();
    var info2 = _prefs!.getString(PREFERENCE_LASTCMD_INCOMINGINFO2);

    if(info2 != null) {
      Map<String, dynamic> map = jsonDecode(info2);
      var cmd = IncomingInfo2.fromJson(map);
      return cmd;
    }
    return null;
  }
}
