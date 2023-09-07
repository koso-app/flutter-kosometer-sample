import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kosometer/channel/flutter-talkie.dart';
import 'package:kosometer/transaction/kawasaki/freehex.dart';
import 'package:string_validator/string_validator.dart';

class PageFreeHex extends StatefulWidget {
  const PageFreeHex({Key? key}) : super(key: key);

  @override
  State<PageFreeHex> createState() => _PageFreeHexState();
}

class _PageFreeHexState extends State<PageFreeHex> {
  final TextEditingController fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('INPUT HEX STRING (case ignored)'),
          SizedBox(
            height: 16,
          ),
          TextField(
            controller: fieldController,
            decoration: InputDecoration(
              hintText: 'BEFF0001',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
            maxLines: null,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: 48,
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      var text = fieldController.text;
                      if (isHexadecimal(text)) {
                        var cmd = FreeHexKawasaki(text);
                        talkie.sendFreeHexKawasaki(cmd);
                      }else{
                        Fluttertoast.showToast(msg: 'invalid hex');
                      }
                    },
                    child: const Text('SEND'))),
          )
        ],
      ),
    );
  }
}
