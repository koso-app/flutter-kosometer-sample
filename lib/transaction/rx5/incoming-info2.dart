import '../base-incoming.dart';

class IncomingInfo2 extends BaseIncoming {
  final int odo;
  final int odo_total;
  final int average_speed;
  final int rd_time; //總騎乘時間 sec, 16bit
  final int average_consume; //平均油耗L/H, 16 bits
  final int trip_1; //小里程數 m, 32bits
  final int trip_1_time; //單位sec, 32bits
  final int trip_1_average_speed; //16bits
  final int trip_1_average_consume; //16bits

  final int trip_2; //小里程數 m, 32bits
  final int trip_2_time; //單位sec, 32bits
  final int trip_2_average_speed; //16bits
  final int trip_2_average_consume; //16bits

  final int trip_a; //自動騎乘時間, 32bits
  final int al_time; //總時間紀錄, 32bits
  final int fuel_range; //km, 32bits
  final int service_DST; //剩餘保養里程, 32bits

  IncomingInfo2(
      this.odo,
      this.odo_total,
      this.average_speed,
      this.rd_time,
      this.average_consume,
      this.trip_1,
      this.trip_1_time,
      this.trip_1_average_speed,
      this.trip_1_average_consume,
      this.trip_2,
      this.trip_2_time,
      this.trip_2_average_speed,
      this.trip_2_average_consume,
      this.trip_a,
      this.al_time,
      this.fuel_range,
      this.service_DST);

  IncomingInfo2.fromJson(Map<String, dynamic> json)
      : odo = json['odo'],
        odo_total = json['odo_total'],
        average_speed = json['average_speed'],
        rd_time = json['rd_time'],
        average_consume = json['average_consume'],
        trip_1 = json['trip_1'],
        trip_1_time = json['trip_1_time'],
        trip_1_average_speed = json['trip_1_average_speed'],
        trip_1_average_consume = json['trip_1_average_consume'],
        trip_2 = json['trip_2'],
        trip_2_time = json['trip_2_time'],
        trip_2_average_speed = json['trip_2_average_speed'],
        trip_2_average_consume = json['trip_2_average_consume'],
        trip_a = json['trip_a'],
        al_time = json['al_time'],
        fuel_range = json['fuel_range'],
        service_DST = json['service_DST'];

  Map<String, dynamic> toJson() => {
        'odo': odo,
        'odo_total': odo_total,
        'average_speed': average_speed,
        'rd_time': rd_time,
        'average_consume': average_consume,
        'trip_1': trip_1,
        'trip_1_time': trip_1_time,
        'trip_1_average_speed': trip_1_average_speed,
        'trip_1_average_consume': trip_1_average_consume,
        'trip_2': trip_2,
        'trip_2_time': trip_2_time,
        'trip_2_average_speed': trip_2_average_speed,
        'trip_2_average_consume': trip_2_average_consume,
        'trip_a': trip_a,
        'al_time': al_time,
        'fuel_range': fuel_range,
        'service_DST': service_DST
      };
}
