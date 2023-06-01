import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;

import '/utils/permission-util.dart';

class PermissionScreen extends StatelessWidget {
  VoidCallback callback;

  PermissionScreen({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 72,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                AppLocalizations.of(context)!.needPermissions,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    requestPermission(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check),
                      Text(AppLocalizations.of(context)!.grantPermission),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(), primary: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermission(BuildContext context) async {
    if (Platform.isIOS) {
      if (!await Permission.bluetooth.isGranted) {
        await Permission.bluetooth.request();
      }
    } else if (Platform.isAndroid) {
      if (!await Permission.bluetoothConnect.isGranted) {
        await Permission.bluetoothConnect.request();
      }

      if (!await Permission.bluetoothScan.isGranted) {
        await Permission.bluetoothScan.request();
      }
    }

    if (!await Permission.locationWhenInUse.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    if(await isPermanentDenied()){
      showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.permissionsDenied),
              content: Text(AppLocalizations.of(context)!.grantInSettings),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.ok))
              ],
            );
          });
    } else {
      callback();
    }
  }
}
