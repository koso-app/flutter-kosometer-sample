import 'dart:async';

class LogManager {
  static LogManager? _instance;

  final StreamController<List<LogItem>> _controller = StreamController<List<LogItem>>.broadcast();
  List<LogItem> list = [];

  static LogManager get(){
    return _instance ??= LogManager();
  }

  Stream<List<LogItem>> stream() {
    return _controller.stream;
  }

  void push(LogItem item) {
    list.add(item);
    _controller.sink.add(list);
  }

  void clear(){
    list.clear();
    _controller.sink.add(list);
  }
}

class LogItem {
  String title;
  String content;
  String hex;
  int timestamp;
  int direction; // send: 1, received: 2, no define: 0

  LogItem({required this.title, this.content = '', this.hex = '', required this.timestamp, this.direction = 0});

  LogItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        hex = json['hex'],
        timestamp = json['timestamp'],
        direction = json['direction'];
}
