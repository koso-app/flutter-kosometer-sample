import '../base-outgoing.dart';
import '/rx5/base-incoming.dart';
import '/rx5/base-outgoing.dart';

class NaviInfoKawasaki extends BaseOutgoing {
  int turndistance;
  int distanceunit;
  int turntype;

  NaviInfoKawasaki(this.turndistance, this.distanceunit, this.turntype);

  NaviInfoKawasaki.fromJson(Map<String, dynamic> json)
      : turndistance = json['turndistance'],
        distanceunit = json['distanceunit'],
        turntype = json['turntype'];

  Map<String, dynamic> toJson() => {
        'turndistance': turndistance,
        'distanceunit': distanceunit,
        'turntype': turntype,
      };
}
