import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/travel_info_providers.dart';
import 'package:mototravel/src/utils/shared_pref.dart';

class DriverTravelController {
BuildContext context;
GlobalKey<ScaffoldState> key = new GlobalKey();
Function refresh;
SharedPref _sharedPref;

String from;
String to;
String idClient;
Client client;

ClientProvider _clientProvider;
TravelInfoProvider _travelInfoProvider;
AuthProvider _authProvider;
GeoFireProvider _geoFireProvider;

Timer _timer; 
int seconds = 30;

Future init (BuildContext context, Function refresh ) 
{
  this.context = context;
  this.refresh = refresh; 
  _sharedPref = new SharedPref();
  _sharedPref.save('isNotification', 'false');
  _clientProvider = new ClientProvider();
 _travelInfoProvider = new TravelInfoProvider();
 _authProvider = new AuthProvider(); 
 _geoFireProvider = new GeoFireProvider();
  //captura de datos desde el main.activity
  Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
  //new version Notification get data
  from = arguments['origin'];
  to = arguments['destination'];
  idClient = arguments['idClient'];

  getClientInfo();
  timeout();
 
}
 
void dispose()
{
  _timer?.cancel();
}

void timeout()
{
  _timer = Timer.periodic(Duration(seconds: 1), (timer) { 
    seconds = seconds - 1;
    refresh();
    if (seconds  == 0)
    {
       cancelTravel();
    }
  });
}  
//datos que actualizaremos desde nuestra base de datos
void acceptViaje()
{
Map<String,dynamic> data = {
  'idDriver': _authProvider.getUser().uid,
  'status': 'accepted'
};
 _timer?.cancel();
_travelInfoProvider.update(data, idClient);
_geoFireProvider.delete(_authProvider.getUser().uid);
//cambiar al primero cuando finalize las pruebas test
Navigator.pushNamedAndRemoveUntil(context,'driver/travel/map', (route) => false, arguments: idClient);
//Navigator.pushNamed(context,'driver/travel/map', arguments: idClient);
}

void cancelTravel()
{
    Map<String,dynamic> data = {
  'status': 'no_accepted'
};
  _timer?.cancel();
_travelInfoProvider.update(data, idClient);
Navigator.pushNamedAndRemoveUntil(context,'driver/map', (route) => false);
}
//obtenemos la informacion del cliente para mostrarle al conductor 
void  getClientInfo() async

{
 client  = await _clientProvider.getById(idClient);
  refresh();
}

}