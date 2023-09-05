import 'package:flutter/material.dart';
import 'package:kosometer/channel/flutter-talkie.dart';
import 'package:kosometer/rx5/naviinfo.dart';

class PageNavigation extends StatefulWidget {
  const PageNavigation({Key? key}) : super(key: key);

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  String mode = "0";
  String city = "台北市";
  String road = "忠孝東路";
  String house = "12";
  int limit_kmh = 60;
  int limit_mph = 37;
  String next_road = "林森北路";
  int next_turn_distance = 40;
  int next_type = 2;
  int camera_distance = 50;
  int total_distance = 120;
  int total_time = 3210;
  int satellite = 8;
  int heading = 123;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                PropertyEditor(
                    desc: "Mode",
                    defaultText: mode,
                    callback: (String input) {
                      mode = input;
                    }),
                PropertyEditor(
                    desc: "City name",
                    defaultText: city,
                    callback: (String input) {
                      city = input;
                    }),
                PropertyEditor(
                    desc: "Road name",
                    defaultText: road,
                    callback: (String input) {
                      road = input;
                    }),
                PropertyEditor(
                    desc: "House",
                    defaultText: house,
                    callback: (String input) {
                      house = input;
                    }),
                PropertyEditor(
                    desc: "Limmit speed (KMH)",
                    defaultText: limit_kmh.toString(),
                    callback: (String input) {
                      limit_kmh = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Limmit speed (MPH)",
                    defaultText: limit_mph.toString(),
                    callback: (String input) {
                      limit_mph = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Next road",
                    defaultText: next_road,
                    callback: (String input) {
                      next_road = input;
                    }),
                PropertyEditor(
                    desc: "Turn distance",
                    defaultText: next_turn_distance.toString(),
                    callback: (String input) {
                      next_turn_distance = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Turn type",
                    defaultText: next_type.toString(),
                    callback: (String input) {
                      next_type = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Camera distance (meter)",
                    defaultText: camera_distance.toString(),
                    callback: (String input) {
                      camera_distance = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Total distance (meter)",
                    defaultText: total_distance.toString(),
                    callback: (String input) {
                      total_distance = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Total time (mins)",
                    defaultText: total_time.toString(),
                    callback: (String input) {
                      total_time = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Satellite",
                    defaultText: satellite.toString(),
                    callback: (String input) {
                      satellite = int.parse(input);
                    }),
                PropertyEditor(
                    desc: "Gps heading",
                    defaultText: heading.toString(),
                    callback: (String input) {
                      heading = int.parse(input);
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
                  var cmd = NaviInfo(city, road, house, limit_kmh, limit_kmh, limit_mph, next_road, next_turn_distance, next_type,
                      camera_distance, total_distance, total_time, satellite, heading);
                  talkie.sendNaviInfo(cmd);
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
