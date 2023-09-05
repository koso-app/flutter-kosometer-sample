import '../base-incoming.dart';

class IncomingUnknow extends BaseIncoming {
  final List<int> raw;
  final String hexString;


  IncomingUnknow(
      this.raw,
      this.hexString);

  IncomingUnknow.fromJson(Map<String, dynamic> json)
      : raw = (json['raw'] as List).map((e) => e as int).toList(),
        hexString = json['hexString'];

  Map<String, dynamic> toJson() => {
        'hexString': hexString,
        'raw': raw,
      };
}
