// To parse this JSON data, do
//
//     final travelInfo = travelInfoFromJson(jsonString);

import 'dart:convert';

TravelInfo travelInfoFromJson(String str) => TravelInfo.fromJson(json.decode(str));

String travelInfoToJson(TravelInfo data) => json.encode(data.toJson());

class TravelInfo {
    TravelInfo({
        this.id,
        this.status,
        this.idDriver,
        this.from,
        this.to,
        this.idTravelHistory,
        this.fromLat,
        this.fromLhg,
        this.toLat,
        this.toLhg,
        this.costo,
    });

    String id;
    String status;
    String idDriver;
    String from;
    String to;
    String idTravelHistory;
    double fromLat;
    double fromLhg;
    double toLat;
    double toLhg;
    double costo;

    factory TravelInfo.fromJson(Map<String, dynamic> json) => TravelInfo(
        id: json["id"],
        status: json["status"],
        idDriver: json["idDriver"],
        from: json["from"],
        to: json["to"],
        idTravelHistory: json["idTravelHistory"],
        fromLat: json["fromLat"]?.toDouble() ?? 0,
        fromLhg: json["fromLhg"]?.toDouble() ?? 0,
        toLat: json["toLat"]?.toDouble() ?? 0,
        toLhg: json["toLhg"]?.toDouble() ?? 0,
        costo: json["costo"]?.toDouble() ?? 0,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "idDriver": idDriver,
        "from": from,
        "to": to,
        "idTravelHistory": idTravelHistory,
        "fromLat": fromLat,
        "fromLhg": fromLhg,
        "toLat": toLat,
        "toLhg": toLhg,
        "costo": costo,
    };
}
