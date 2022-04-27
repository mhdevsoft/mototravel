// To parse this JSON data, do
//
//     final costos = costosFromJson(jsonString);

import 'dart:convert';
Costos costosFromJson(String str) => Costos.fromJson(json.decode(str));

String costosToJson(Costos data) => json.encode(data.toJson());

class Costos {
    Costos({
        this.km,
        this.min,
        this.minValue,
    });

    int km;
    double min;
    double minValue;

    factory Costos.fromJson(Map<String, dynamic> json) => Costos(
        km: json["km"],
        min: json["min"],
        minValue: json["minValue"],
    );

    Map<String, dynamic> toJson() => {
        "km": km,
        "min": min,
        "minValue": minValue,
    };
}
