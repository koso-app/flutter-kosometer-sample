import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home.dart';
import 'screen/screen_permission.dart';
import 'utils/permission_util.dart';

void main() {
  runApp(const MyApp());
}

enum PermissionState {
  unknown,
  noPermission,
  firstTime,
  normal,
}

PermissionState permissionState = PermissionState.unknown;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    checkPermission().then((allow) {
      setState(() {
        permissionState = allow ? PermissionState.normal : PermissionState.noPermission;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: check(),
    );
  }

  Widget check() {
    switch (permissionState) {
      case PermissionState.unknown:
        return Container(color: Colors.blue,);
      case PermissionState.noPermission:
        return PermissionScreen(callback: () {
          checkPermission().then((value) {
            if (value) {
              setState(() => permissionState = PermissionState.normal);
            }
          });
        });
      case PermissionState.firstTime:
        // return IntroScreen(callback: () {
        //   setState(() => permissionState = PermissionState.normal);
        // });
        return const HomeScreen();
      case PermissionState.normal:
        return const HomeScreen();
    }
  }
}
