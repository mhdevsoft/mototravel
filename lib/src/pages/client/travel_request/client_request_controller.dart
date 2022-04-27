
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/models/travel_info.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/pages/providers/travel_info_providers.dart';
import 'package:mototravel/src/models/driver.dart';
import 'package:mototravel/src/utils/snackbar.dart' as utils;

class TravelClientRequest 
{
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
   
   
  String from;
  String to;
  LatLng fromLatLhg;
  LatLng toLatLhg;

  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  GeoFireProvider _geoFireProvider;
  PushNotificationsProvider _pushNotificationsProvider;
  List<String> nearbyDrivers = new List();
  StreamSubscription<List<DocumentSnapshot>> _streamSubscription;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;
   //Instancias de nuestro constructor
  Future init (BuildContext context, Function refresh)
  {
     this.context = context;
     this.refresh = refresh;
     _travelInfoProvider = new TravelInfoProvider();
     _authProvider = new AuthProvider();
     _driverProvider = new DriverProvider();
     _geoFireProvider = new GeoFireProvider();
     _pushNotificationsProvider = new PushNotificationsProvider();
    Map<String, dynamic> argument = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    from = argument['from'];
    to = argument['to'];
    fromLatLhg = argument['fromLatLng'];
    toLatLhg= argument['toLatLng']; 
    _createTravelInfo();
    _getNearbyDrivers();

    
    
  }
  //si un conductor acepto el viaje lo lleve a la pantalla de viaje
   void _checkDriverRespuesta()
   {
     Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
       _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());

      if (travelInfo.idDriver != null && travelInfo.status == 'accepted') {
       Navigator.pushNamedAndRemoveUntil(context, 'client/viaje/map', (route) => false);
       // Navigator.pushReplacementNamed(context, 'client/viaje/map');
      }
       else if(travelInfo.status == 'no_accepted')
      {
       utils.Snackbar.showSnackbar(context, key, 'El Mototaxi no pudo aceptar tu viaje intentalo de nuevo');
       Future.delayed(Duration(milliseconds: 2000), (){
          Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
       });
       
      }


    });
   }
//cancela los datos si regresamos para que estos no se esten escuchando a las demas pantallas
  void disponse()
  {
      _streamSubscription?.cancel();
      _streamStatusSubscription?.cancel();
  }
  //Busca conductores y espera uno para llevarlo a viaje
  void _getNearbyDrivers()
  {
    Stream<List<DocumentSnapshot>> stream = _geoFireProvider.getNearbyDrivers(fromLatLhg.latitude,
     fromLatLhg.longitude,
     1
     );
     _streamSubscription =  stream.listen((List<DocumentSnapshot> documentList) { 
        for (DocumentSnapshot d in documentList) {
           print('Conductor Encontrado ${d.id}');
           nearbyDrivers.add(d.id);

        }
         getDriverInfo(nearbyDrivers[0]);
         _streamSubscription?.cancel();
      });
    
  }
  //crea su informacion de viaje para que este sea manipulado o usado durante el viaje
  void _createTravelInfo()async
  {
    TravelInfo travelInfo = new TravelInfo(
     id: _authProvider.getUser().uid,
     from: from,
     to: to,
     fromLat: fromLatLhg.latitude,
     fromLhg: fromLatLhg.longitude,
     toLat: toLatLhg.latitude,
     toLhg: toLatLhg.longitude,
     status: 'created'
    );

    await _travelInfoProvider.create(travelInfo);
    //checa la respuesta del conductor
    _checkDriverRespuesta();
  }

   //Obtener token
   Future<void> getDriverInfo(String idDriver)async
   {
     Drive drive = await _driverProvider.getById(idDriver);
     _sendNotification(drive.token);
   }



  //Enviar Notificaciones al Conductor
  void _sendNotification(String token)
  {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'idClient': _authProvider.getUser().uid,
      'origin': from,
      'destination': to,
    };
    _pushNotificationsProvider.sendMessage(token, data, '¡Se ha solicitado un Viaje!', 'Un cliente ha solitidado un Mototaxi Aceptalo para llevarlo a su destino');
  }
}