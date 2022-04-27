import 'package:google_maps_flutter/google_maps_flutter.dart';
class Datainfo
{
//modela los datos del JSON

String text;
int value;

Datainfo ({
  this.text,
  this.value

});

Datainfo.fromJsonMap(Map<String, dynamic> json)
{
  text = json['text'];
  value = json['value']; 
}

}

class Direction 
{
 Datainfo distance;
 Datainfo duration;
 String startAddress;
 String endAddress;
 LatLng startLocation;
 LatLng endLocation;

 Direction({
  //Instanciamos las variables 
   this.startAddress,
   this.endAddress,
   this.startLocation,
   this.endLocation
 });

//recibimos los datos JSON del mapa
 Direction.fromJsonMap(Map<String, dynamic> json)
 {
   distance = new Datainfo.fromJsonMap(json['distance']);
   duration = new Datainfo.fromJsonMap(json['duration']);
   startAddress = json['start_address'];
   endAddress = json['end_address'];
   duration = new Datainfo.fromJsonMap(json['duration']);
   startLocation = new LatLng(json['start_location']['lat'], json['start_location']['lng']);
   endLocation = new LatLng(json['end_location']['lat'], json['end_location']['lng']);

 }
 Map<String, dynamic> toJson() =>
 {
  'distance': distance.text,
  'duration': duration.text,
 };
}