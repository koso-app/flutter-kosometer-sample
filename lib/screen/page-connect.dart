import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/utils/shared-preference.dart';

import '../channel/flutter-talkie.dart';
import '../manager/connect-manager.dart';

class PageConnect extends StatefulWidget {
  const PageConnect({Key? key}) : super(key: key);

  @override
  State<PageConnect> createState() => _PageConnectState();
}

class _PageConnectState extends State<PageConnect> {
  ConnectState state = connectManager.state;
  String desc = "disconnected";
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    sub = connectManager.stateStream.listen((event) {
      setState(() {
        updateState(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    updateState(state);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: Text(
            desc.toUpperCase(),
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        SizedBox(
            width: 200,
            height: 64,
            child: StreamBuilder<ConnectState>(
                stream: connectManager.stateStream,
                builder: (context, snapshot) {
                  return getStateButton(snapshot.data ?? state);
                })),
        TextButton(
            onPressed: () {
              talkie.sendScan();
              showScanDialog();
            },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Scan", style: TextStyle(fontSize: 20)),
            ),)
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  Widget getStateButton(ConnectState state) {
    switch (state) {
      case ConnectState.Disconnected:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {

                  var address = Preference.instance().getLastConnectAddress();
                  if (address != null) {
                    talkie.sendConnect(address);
                  } else {
                    talkie.sendScan();
                    showScanDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                    backgroundColor: Colors.redAccent),
                child: Text(
                  AppLocalizations.of(context)!.connect.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )));
      case ConnectState.Connecting:
        return SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 16,
                ),
                Text("${AppLocalizations.of(context)!.connecting}...",
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ));
      case ConnectState.Discovering:
        return SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 16,
                ),
                Text("${AppLocalizations.of(context)!.scanning}...",
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ));
      default:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  talkie.sendEnd();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.disconnect.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )));
    }
  }

  showScanDialog() {
    showDialog(
        context: context,
        builder: (c) {
          return const AlertDialog(
            title: Text('Scanning list'),
            content: ScanResultsList(),
          );
        }).then((value) {
      talkie.sendStopScan();
      // if(connectManager.state != ConnectState.Connected || connectManager.state != ConnectState.Connecting){
      //   connectManager.state = ConnectState.Disconnected;
      // }
    });
  }

  void updateState(ConnectState event) {
    state = event;
    switch (event) {
      case ConnectState.Connected:
        desc = AppLocalizations.of(context)!.connected;
        break;
      case ConnectState.Discovering:
        desc = AppLocalizations.of(context)!.scanning;
        break;
      case ConnectState.Connecting:
        desc = AppLocalizations.of(context)!.connecting;
        break;
      default:
        desc = AppLocalizations.of(context)!.disconnected;
    }
  }
}

class ScanResultsList extends StatefulWidget {
  const ScanResultsList({Key? key}) : super(key: key);

  @override
  State<ScanResultsList> createState() => _ScanResultsListState();
}

class _ScanResultsListState extends State<ScanResultsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        stream: talkie.candidatesStream,
        initialData: [],
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          var data = snapshot.data ?? [];
          List<dynamic> candidates = [];
          data.forEach((element) {
            var found = false;
            candidates.forEach((c) {
              if (element['address'] == c['address']) {
                found = true;
              }
            });
            if (!found) {
              candidates.add(element);
            }
          });
          return Container(
            width: 300,
            height: 200,
            child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (c, index) {
                  var name = candidates[index]['name'];
                  var address = candidates[index]['address'];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(name ?? ''),
                    subtitle: Text(address ?? ''),
                    onTap: () {
                      Navigator.pop(context);
                      talkie.sendStopScan();
                      // talkie.sendConnect(address);
                      talkie.sendConnect(address);
                      Preference.instance().putLastConnectAddress(address);
                    },
                  );
                }),
          );
        });
  }
}
