import '../base-outgoing.dart';
import '/rx5/base-incoming.dart';
import '/rx5/base-outgoing.dart';

class NaviInfoKawasaki extends BaseOutgoing {
  int mode;
  int seqnum;
  int turndistance;
  int distanceunit;
  int turntype;

  NaviInfoKawasaki(this.mode, this.seqnum, this.turndistance, this.distanceunit, this.turntype);

  NaviInfoKawasaki.fromJson(Map<String, dynamic> json)
      : mode = json['mode'],
        seqnum = json['seqnum'],
        turndistance = json['turndistance'],
        distanceunit = json['distanceunit'],
        turntype = json['turntype'];

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'seqnum': seqnum,
        'turndistance': turndistance,
        'distanceunit': distanceunit,
        'turntype': turntype,
      };
}
