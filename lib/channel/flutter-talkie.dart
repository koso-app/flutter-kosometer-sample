import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kosometer/manager/log-manager.dart';
import 'package:kosometer/transaction/rx5/incoming-unknow.dart';
import '../transaction/base-incoming.dart';
import '../transaction/kawasaki/naviinfo.dart';
import '../transaction/rx5/incoming-info1.dart';
import '../transaction/rx5/incoming-info2.dart';
import '../transaction/rx5/naviinfo.dart';
import '/manager/connect-manager.dart';

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
          LogManager.get().push(LogItem(title: "incoming info 1", content: "${cmd.toString()}", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 2));
          break;
        case 'incominginfo2':
          var json = call.arguments;
          Map<String, dynamic> map = jsonDecode(json);
          var cmd = IncomingInfo2.fromJson(map);
          _incomingSink.add(cmd);
          keepLastIncomingInfo2(json);
          LogManager.get().push(LogItem(title: "incoming info 2", content: "${cmd.toString()}", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 2));
          break;
        case 'incomingunknow':
          var json = call.arguments;
          Map<String, dynamic> map = jsonDecode(json);
          var cmd = IncomingUnknow.fromJson(map);
          _incomingSink.add(cmd);
          LogManager.get().push(LogItem(title: "data source", content: cmd.hexString, timestamp: DateTime.now().millisecondsSinceEpoch, direction: 2));
          break;
        case 'error':
          _errorSink.add(call.arguments);
          break;
        case 'log':
          var json = call.arguments;
          Map<String, dynamic> map = jsonDecode(json);
          LogManager.get().push(LogItem.fromJson(map));
          break;
      }
    });
  }

  Future<String> sendWhatState() async => await platform.invokeMethod('whatstate', null);

  Future sendStartForeground() => platform.invokeMethod('startforeground', null);

  Future sendScan() async{
    platform.invokeMethod('scan', null);
    LogManager.get().push(LogItem(title: "scan", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
    Future.delayed(Duration(seconds: 10)).then((value){
      if(connectManager.state == ConnectState.Discovering) {
        sendStopScan();
        connectManager.state = ConnectState.Disconnected;
      }
    });
  }

  Future sendLeScan() async{

    platform.invokeMethod('lescan');
    LogManager.get().push(LogItem(title: "le scan", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
    Future.delayed(Duration(seconds: 10)).then((value){
      if(connectManager.state == ConnectState.Discovering) {
        sendStopScan();
        connectManager.state = ConnectState.Disconnected;
      }
    });
  }

  Future sendStopScan() async{
    platform.invokeMethod('stopscan', null);
    LogManager.get().push(LogItem(title: "stop scan", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
  }

  Future sendConnect(String address) async {
    platform.invokeMethod('connect', <String, dynamic>{
      'address': address,
    });
    Future.delayed(Duration(seconds: 10)).then((value){
      if(connectManager.state == ConnectState.Discovering) {
        sendStopScan();
        connectManager.state = ConnectState.Disconnected;
      }
    });
    LogManager.get().push(LogItem(title: "connect", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
  }

  Future sendLeConnect(String address) async{
        platform.invokeMethod('leconnect', <String, dynamic>{
          'address': address,
        });
        Future.delayed(Duration(seconds: 6)).then((value){
          if(connectManager.state == ConnectState.Discovering) {
            sendStopScan();
            connectManager.state = ConnectState.Disconnected;
          }
        });
        LogManager.get().push(LogItem(title: "le connect", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
      }

  Future sendEnd() async {
    platform.invokeMethod('disconnect', null);
    LogManager.get().push(LogItem(title: "end", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
  }

  Future sendNaviInfo(NaviInfo cmd) {
    LogManager.get().push(LogItem(title: "naviinfo", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 1));
    var j = json.encode(cmd);
    return platform.invokeMethod('naviinfo', <String, dynamic>{
      'naviinfo': j,
    });
  }

  Future sendNaviInfoKawasaki(NaviInfoKawasaki cmd){
    LogManager.get().push(LogItem(title: "naviinfo-kawasaki", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 1));
    var j = json.encode(cmd);
    return platform.invokeMethod('naviinfo-kawasaki', <String, dynamic>{
      'naviinfo-kawasaki': j,
    });
  }

  Future startAncs() async{
    LogManager.get().push(LogItem(title: "start ANCS", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));
    platform.invokeMethod('start_ancs');
  }

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
