import '../base-incoming.dart';

class IncomingKawasaki extends BaseIncoming {
  final String title;
  final List<int> raw;
  final String hexString;


  IncomingKawasaki(
      this.title,
      this.raw,
      this.hexString);

  IncomingKawasaki.fromJson(Map<String, dynamic> json)
      : raw = (json['raw'] as List).map((e) => e as int).toList(),
        hexString = json['hexString'],
        title = json['title'];

  Map<String, dynamic> toJson() => {
        'hexString': hexString,
        'raw': raw,
        'title': title,
      };
}
