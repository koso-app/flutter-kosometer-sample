import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

Future<bool> checkPermission() async {
  var success = true;

  if (Platform.isIOS) {
    success = success && await Permission.bluetooth.isGranted;
  } else if (Platform.isAndroid) {
    success = success && await Permission.bluetoothConnect.isGranted;
    success = success && await Permission.bluetoothScan.isGranted;
  }

  success = success && await Permission.locationWhenInUse.isGranted;

  return success;
}

Future<bool> isPermanentDenied() async{
  var denied = false;

  if (Platform.isIOS) {
    var states = await [
      Permission.bluetooth,
      Permission.locationWhenInUse,
    ].request();
    for(PermissionStatus v in states.values){
      if(v == PermissionStatus.permanentlyDenied){
        denied = true;
      }
    }
  } else if (Platform.isAndroid) {
    // denied = denied || await Permission.bluetoothConnect.isPermanentlyDenied;
    // denied = denied || await Permission.bluetoothScan.isPermanentlyDenied;
    var states = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();
    for(PermissionStatus v in states.values){
      if(v == PermissionStatus.permanentlyDenied){
        denied = true;
      }
    }
  }


  return denied;
}