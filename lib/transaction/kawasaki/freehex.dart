import 'package:kosometer/transaction/base-outgoing.dart';

class FreeHexKawasaki extends BaseOutgoing {

  String hexString = '';
  FreeHexKawasaki(this.hexString);

  FreeHexKawasaki.fromJson(Map<String, dynamic> json)
      : hexString = json['hexString'];

  Map<String, dynamic> toJson() => {
    'hexString': hexString
  };
}
