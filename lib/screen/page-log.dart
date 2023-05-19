import 'package:flutter/material.dart';

class PageLog extends StatefulWidget {
  const PageLog({Key? key}) : super(key: key);

  @override
  State<PageLog> createState() => _PageLogState();
}

class _PageLogState extends State<PageLog> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(title: Text("TExt"),);
      },
    );
  }
}
