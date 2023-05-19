import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kosometer/manager/log-manager.dart';

class PageLog extends StatefulWidget {
  const PageLog({Key? key}) : super(key: key);

  @override
  State<PageLog> createState() => _PageLogState();
}

class _PageLogState extends State<PageLog> {
  List<LogItem> list = LogManager.get().list;

  StreamSubscription<List<LogItem>>? sub;

  @override
  void initState() {
    super.initState();
    sub = LogManager.get().stream().listen((event) {
      setState(() {
        list = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        var item = list[index];
        var time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);

        return ListTile(
          leading: Icon(getIcon(item)),
          title: Text(item.title),
          subtitle: Text(item.content),
          trailing: Text("${time.hour}:${time.minute}:${time.second}-${time.millisecond}"),
        );
      },
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  IconData? getIcon(LogItem item) {
    if(item.direction == 1){
      return Icons.arrow_back;
    } else if(item.direction == 2){
      return Icons.arrow_forward;
    } else {
      return Icons.circle;
    }
  }
}
