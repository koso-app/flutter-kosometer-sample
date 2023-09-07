import 'base-outgoing.dart';

class NaviInfo extends BaseOutgoing {
  int navimode = 0;
  String ctname;
  String roadname;
  String doornum;
  int alertkmh;
  int alertmph;
  int limitms; // deprecated
  int limitkmh;
  int limitmph;
  String nextroadname;
  int nextdist;
  int nextturn;
  int camera;
  int navidist;
  int navitime;
  int gpsnum;
  int gpsdir;

  NaviInfo(this.ctname, this.roadname, this.doornum,this.alertkmh, this.alertmph, this.limitms, this.limitkmh, this.limitmph, this.nextroadname, this.nextdist,
      this.nextturn, this.camera, this.navidist, this.navitime, this.gpsnum, this.gpsdir);

  NaviInfo.fromJson(Map<String, dynamic> json)
      : navimode = json['navimode'],
        ctname = json['ctname'],
        roadname = json['roadname'],
        doornum = json['doornum'],
        alertkmh = json['alertkmh'],
        alertmph = json['alertmph'],
        limitms = json['limitsp'],
        limitkmh = json['limitkmh'],
        limitmph = json['limitmph'],
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
        'alertkmh': alertkmh,
        'alertmph': alertmph,
        'limitsp': limitms,
        'limitkmh': limitkmh,
        'limitmph': limitmph,
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
