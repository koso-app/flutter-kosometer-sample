import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:kosometer/manager/log-manager.dart';

import '/channel/flutter-talkie.dart';
import '/utils/shared-preference.dart';

enum ConnectState { Disconnected, Discovering, Connected, Connecting }

var connectManager = ConnectManager();

class ConnectManager {
  ConnectState _state = ConnectState.Disconnected;
  final StreamController<ConnectState> _stateController = StreamController.broadcast();
  StreamSink<ConnectState> get _stateSink => _stateController.sink;
  Stream<ConnectState> get stateStream => _stateController.stream;

  bool _connected = false;

  set state(ConnectState value) {
    _state = value;
    _stateSink.add(value);

    LogManager.get().push(LogItem(title: "${value.name}", content: "", timestamp: DateTime.now().millisecondsSinceEpoch, direction: 0));

    switch(value){
      case ConnectState.Connected:
        _connected = true;
        talkie.startAncs();
        break;
      case ConnectState.Disconnected:
        if(_connected){
          _connected = false;
          Geolocator.getLastKnownPosition().then((position) => {
            if (position != null){
              Preference.instance().setDisconnectLocation(
                  [position.latitude, position.longitude], DateTime.now().millisecondsSinceEpoch)
            }
          });
        }
        break;
      default:

    }
  }

  ConnectState get state => _state;

  ConnectManager() {
    talkie.sendWhatState().then((state) {
      this.state = getConnectStateFromString(state);
    });
  }
}

ConnectState getConnectStateFromString(String text) {
  if (text == ConnectState.Discovering.name) return ConnectState.Discovering;
  if (text == ConnectState.Connected.name) return ConnectState.Connected;
  if (text == ConnectState.Connecting.name)
    return ConnectState.Connecting;
  else
    return ConnectState.Disconnected;
}
