import '/rx5/base_incoming.dart';

class IncomingInfo1 extends BaseIncoming {
  final int speed;
  final int rpm;
  final batt_vc;
  final consume;
  final gear;
  final fuel;

  IncomingInfo1(this.speed, this.rpm, this.batt_vc, this.consume, this.gear, this.fuel);

  IncomingInfo1.fromJson(Map<String, dynamic> json)
      : speed = json['speed'],
        rpm = json['rpm'],
        batt_vc = json['batt_vc'],
        consume = json['consume'],
        gear = json['gear'],
        fuel = json['fuel'];

  Map<String, dynamic> toJson() =>
      {
        'speed': speed,
        'rpm': rpm,
        'batt_vc': batt_vc,
        'consume': consume,
        'gear': gear,
        'fuel': fuel
      };
}