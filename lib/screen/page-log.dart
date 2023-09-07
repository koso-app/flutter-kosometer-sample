import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosometer/manager/log-manager.dart';

class PageLog extends StatefulWidget {
  const PageLog({Key? key}) : super(key: key);

  @override
  State<PageLog> createState() => _PageLogState();
}

class _PageLogState extends State<PageLog> {
  List<LogItem> list = LogManager
      .get()
      .list;
  StreamSubscription<List<LogItem>>? sub;
  bool sortDesc = true;
  TextEditingController keywordController = TextEditingController();
  String filterKeyword = '';

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

    var resultList = list.where((element) =>
    element.title.toLowerCase().contains(filterKeyword.toLowerCase()) ||
        element.content.toLowerCase().contains(filterKeyword.toLowerCase()))
        .toList();
    if (sortDesc) {
      resultList.sort((a, b) =>( a.timestamp.compareTo(b.timestamp)));
    }else{
      resultList.sort((a, b) =>( b.timestamp.compareTo(a.timestamp)));
    }
    return Container(
      height: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        sortDesc = !sortDesc;
                      });
                    },
                    icon: sortDesc ? const Icon(Icons.arrow_downward) : const Icon(Icons.arrow_upward)),
                IconButton(
                    onPressed: () {
                      LogManager.get().clear();
                    },
                    icon: Icon(Icons.cleaning_services)),
                const Spacer(),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: TextField(
                    maxLines: 1,
                    controller: keywordController,
                    decoration: InputDecoration(
                        hintText: 'Filter by text',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            width: 1,
                          ),
                        )),
                    onChanged: (text) {
                      setState(() {
                        filterKeyword = text.trim();
                      });
                    },
                  ),
                )
              ]),
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: resultList.length,
              itemBuilder: (BuildContext context, int index) {
                var item = resultList[index];
                var time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);

                return ListTile(
                  leading: Icon(getIcon(item)),
                  title: Text(item.title),
                  subtitle: Text(item.content),
                  trailing: Text("${time.hour}:${time.minute}:${time.second}-${time.millisecond}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  IconData? getIcon(LogItem item) {
    if (item.direction == 1) {
      return Icons.arrow_back;
    } else if (item.direction == 2) {
      return Icons.arrow_forward;
    } else {
      return Icons.circle;
    }
  }
}
