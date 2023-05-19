import '/rx5/base-incoming.dart';
import 'base-outgoing.dart';

class NaviInfo extends BaseOutgoing {
  int navimode = 0;
  String ctname;
  String roadname;
  String doornum;
  int limitsp;
  String nextroadname;
  int nextdist;
  int nextturn;
  int camera;
  int navidist;
  int navitime;
  int gpsnum;
  int gpsdir;

  NaviInfo(this.ctname, this.roadname, this.doornum, this.limitsp, this.nextroadname, this.nextdist,
      this.nextturn, this.camera, this.navidist, this.navitime, this.gpsnum, this.gpsdir);

  NaviInfo.fromJson(Map<String, dynamic> json)
      : navimode = json['navimode'],
        ctname = json['ctname'],
        roadname = json['roadname'],
        doornum = json['doornum'],
        limitsp = json['limitsp'],
        nextroadname = json['nextroadname'],
        nextdist = json['nextdist'],
        nextturn = json['nextturn'],
        camera = json['camera'],
        navidist = json['navidist'],
        navitime = json['navitime'],
        gpsnum = json['gpsnum'],
        gpsdir = json['gpsdir'];

  Map<String, dynamic> toJson() => {
        'navimode': navimode,
        'ctname': ctname,
        'roadname': roadname,
        'doornum': doornum,
        'limitsp': limitsp,
        'nextroadname': nextroadname,
        'nextdist': nextdist,
        'nextturn': nextturn,
        'camera': camera,
        'navidist': navidist,
        'navitime': navitime,
        'gpsnum': gpsnum,
        'gpsdir': gpsdir,
      };
}
