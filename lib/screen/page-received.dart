import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kosometer/channel/flutter-talkie.dart';

import '../transaction/base-incoming.dart';
import '../transaction/rx5/incoming-info1.dart';
import '../transaction/rx5/incoming-info2.dart';


class PageReceived extends StatefulWidget {
  const PageReceived({Key? key}) : super(key: key);

  @override
  State<PageReceived> createState() => _PageReceivedState();
}

class _PageReceivedState extends State<PageReceived> {

  StreamSubscription? sub;
  String? fuel;
  String? batt_vc;
  String? speed;
  String? consume;
  String? gear;
  String? rpm;

  String? odo;
  String? odo_total;
  String? al_time;
  String? avg_consume;
  String? avg_speed;
  String? fuel_range;

  String? rd_time;
  String? service_dst;

  String? trip1;
  String? trip1_avg_consume;
  String? trip1_avg_speed;
  String? trip1_time;
  String? trip2;
  String? trip2_avg_consume;
  String? trip2_avg_speed;
  String? trip2_time;

  String? trip_a;

  @override
  void initState() {
    super.initState();
    sub = talkie.incomingStream.listen((BaseIncoming event) =>  setState(() {
        if (event is IncomingInfo1) {
          fuel = event.fuel.toString();
          batt_vc = event.batt_vc.toString();
          speed = event.speed.toString();
          consume = event.consume.toString();
          gear = event.gear.toString();
          rpm = event.rpm.toString();
        }
        if (event is IncomingInfo2) {
          odo = event.odo.toString();
          odo_total = event.odo_total.toString();
          al_time = event.al_time.toString();
          avg_consume = event.average_consume.toString();
          avg_speed = event.average_speed.toString();
          fuel_range = event.fuel_range.toString();
          rd_time = event.rd_time.toString();
          service_dst = event.service_DST.toString();
          trip1 = event.trip_1.toString();
          trip1_avg_consume = event.trip_1_average_consume.toString();
          trip1_avg_speed = event.trip_1_average_speed.toString();
          trip1_time = event.trip_1_time.toString();
          trip2 = event.trip_2.toString();
          trip2_avg_consume = event.trip_2_average_consume.toString();
          trip2_avg_speed = event.trip_2_average_speed.toString();
          trip2_time = event.trip_2_time.toString();
          trip_a = event.trip_a.toString();
        }
      })

    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("INFO 1", style: TextStyle(fontSize: 18),),
              ),
              PropertyValue(title: "Fuel (%)", value: fuel),
              PropertyValue(title: "Battery level (%)", value: batt_vc),
              PropertyValue(title: "Speed (km/h)", value: speed),
              PropertyValue(title: "Instant consume", value: consume),
              PropertyValue(title: "Gear", value: gear),
              PropertyValue(title: "Rpm", value: rpm),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("INFO 2", style: TextStyle(fontSize: 18),),
              ),
              PropertyValue(title: "ODO (meter)", value: odo),
              PropertyValue(title: "Total ODO", value: odo_total),
              PropertyValue(title: "Al time", value: al_time),
              PropertyValue(title: "Average consume", value: avg_consume),
              PropertyValue(title: "Average speed", value: avg_speed),
              PropertyValue(title: "Fuel range", value: fuel_range),
              PropertyValue(title: "Ride time", value: rd_time),
              PropertyValue(title: "Service DST", value: service_dst),

              PropertyValue(title: "Trip1", value: trip1),
              PropertyValue(title: "Trip1 avg consume", value: trip1_avg_consume),
              PropertyValue(title: "Trip1 avg speed", value: trip1_avg_speed),
              PropertyValue(title: "Trip1 time", value: trip1_time),
              PropertyValue(title: "Trip2", value: trip2),
              PropertyValue(title: "Trip2 avg consume", value: trip2_avg_consume),
              PropertyValue(title: "Trip2 avg speed", value: trip2_avg_speed),
              PropertyValue(title: "Trip2 time", value: trip2_time),
              PropertyValue(title: "Trip A", value: trip_a),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }
}

class PropertyValue extends StatelessWidget {
  final String title;
  final String? value;

  const PropertyValue({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(value ?? " --- ", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.blue))
          ],
        ),
        const Divider()
      ],
    );
  }
}
