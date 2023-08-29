import 'package:flutter/material.dart';
import 'package:kosometer/channel/flutter-talkie.dart';
import 'package:kosometer/rx5/kawasaki/naviinfo.dart';
import 'package:kosometer/rx5/naviinfo.dart';

class PageNavigation extends StatefulWidget {
  const PageNavigation({Key? key}) : super(key: key);

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {

  int turn_distance = 40;
  int distance_unit = 0;
  int next_type = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                PropertyEditor(
                    desc: "Turn distance",
                    defaultText: turn_distance.toString(),
                    callback: (String input) {
                      turn_distance = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Distance unit",
                    defaultText: distance_unit.toString(),
                    callback: (String input) {
                      turn_distance = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Turn type",
                    defaultText: next_type.toString(),
                    callback: (String input) {
                      next_type = int.parse(input);
                    }),
              ],
            ),
          ),
        ),
        SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
                onPressed: () {
                  var cmd = NaviInfoKawasaki( turn_distance, distance_unit, next_type,);
                  talkie.sendNaviInfoKawasaki(cmd);
                },
                child: Text("Send")))
      ],
    );
  }
}

class PropertyEditor extends StatefulWidget {
  final String desc;
  final String defaultText;
  final Function(String input) callback;

  const PropertyEditor({Key? key, required this.desc, required this.defaultText, required this.callback})
      : super(key: key);

  @override
  State<PropertyEditor> createState() => _PropertyFieldState();
}

class _PropertyFieldState extends State<PropertyEditor> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.defaultText;
    textEditingController.addListener(() {
      widget.callback(textEditingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: textEditingController,
                ),
              ),
              Text("// ${widget.desc}")
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
