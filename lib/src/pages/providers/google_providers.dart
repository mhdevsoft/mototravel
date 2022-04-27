import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mototravel/src/api/enviroment.dart';
import 'package:mototravel/src/models/directions.dart';

class GoogleProvider  {

  Future<dynamic> getGoogleDirection (double fromLat , double fromLhg, double toLat, double toLhg)async
  {
    Uri uri = Uri.https('maps.googleapis.com',
     '/maps/api/directions/json',
     {
       'key': Entorno.API_KEY_MAPS,
       'origin': '$fromLat,$fromLhg',
       'destination':   '$toLat,$toLhg',
       'trafic_model': 'best_guess',
       'departure_time': DateTime.now().microsecondsSinceEpoch.toString(),
       'mode': 'driving',
       'transit_routing_preferences':'less_driving'
     }
     );

     print('URL: $uri');
     //recibe los datos del sitio HTTP para modelarlo que vinene en JSON 
     final response = await http.get(uri);
     final decodeData = json.decode(response.body);
     final leg = new Direction.fromJsonMap(decodeData['routes'][0]['legs'][0]);
     return leg;
  }
}