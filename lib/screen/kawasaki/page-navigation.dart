import 'package:flutter/material.dart';
import 'package:kosometer/channel/flutter-talkie.dart';
import 'package:kosometer/rx5/kawasaki/kawasaki-helper.dart';
import 'package:kosometer/rx5/kawasaki/naviinfo.dart';


class PageNavigationKawasaki extends StatefulWidget {
  const PageNavigationKawasaki({Key? key}) : super(key: key);

  @override
  State<PageNavigationKawasaki> createState() => _PageNavigationKawasakiState();
}

class _PageNavigationKawasakiState extends State<PageNavigationKawasaki> {
  int mode = 0;
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
                  desc: "Mode",
                  defaultText: mode.toString(),
                  callback: (String input) {
                    mode = int.parse(input);
                  },
                  keyboardType: TextInputType.number,
                ),
                PropertyEditor(
                  desc: "Turn distance",
                  defaultText: turn_distance.toString(),
                  callback: (String input) {
                    turn_distance = int.parse(input);
                  },
                  keyboardType: TextInputType.number,
                ),
                PropertyEditor(
                  desc: "Distance unit",
                  defaultText: distance_unit.toString(),
                  callback: (String input) {
                    distance_unit = int.parse(input);
                  },
                  keyboardType: TextInputType.number,
                ),
                PropertyEditor(
                  desc: "Turn type",
                  defaultText: next_type.toString(),
                  callback: (String input) {
                    next_type = int.parse(input);
                  },
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
                onPressed: () {
                  // if(connectManager.state != ConnectState.Connected){
                  //   Fluttertoast.showToast(msg: 'No connection available', backgroundColor: Colors.red);
                  //   return;
                  // }

                  var cmd = NaviInfoKawasaki(
                    mode,
                    getSequenceNumber(),
                    turn_distance,
                    distance_unit,
                    next_type,
                  );
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
  final TextInputType keyboardType;

  const PropertyEditor(
      {Key? key,
      required this.desc,
      required this.defaultText,
      required this.callback,
      this.keyboardType = TextInputType.text})
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
                  keyboardType: widget.keyboardType,
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
