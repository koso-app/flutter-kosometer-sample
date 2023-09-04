import 'package:flutter/material.dart';
import 'package:kosometer/screen/page-log.dart';

import 'screen/page-connect.dart';
import 'screen/page-navigation.dart';
import 'screen/page-received.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: "CONNECT",),
              // Tab(text: "RECEIVED"),
              Tab(text: "NAVIGATION"),
              Tab(text: "LOG"),
            ],
            isScrollable: true,
          ),
        ),
        body: const TabBarView(
          children: [
            PageConnect(),
            // PageReceived(),
            PageNavigationKawasaki(),
            PageLog()
          ],
        ),
      ),
    );
  }
}
