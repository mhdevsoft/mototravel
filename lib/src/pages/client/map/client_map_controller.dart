import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:mototravel/src/api/enviroment.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/colors.dart' as color;
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:flutter_google_places/flutter_google_places.dart';

class ClientMapController 
{
    BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key  = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  //Object
  CameraPosition initialPosicion = CameraPosition(target: LatLng(20.4629037,-97.7017422),
  zoom: 14.0
  );
  
    //Propiedades y Variables Globales
    Position _position;
    StreamSubscription<Position> _positionStream;
    BitmapDescriptor markerDriver;
    GeoFireProvider _geoFireProvider;
    AuthProvider _authProvider;
    DriverProvider _driverProvider;
    ClientProvider _clientProvider;
   PushNotificationsProvider _pushNotificationsProvider;

    bool isConnect = true;
    ProgressDialog _progressDialog;
    Map <MarkerId,Marker> markers = <MarkerId, Marker>{};
    
  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _clientSuscription;
  //modelo JSON
  Client client;

  //Variables Globales

  String from;
  LatLng fromLatLng;
  bool isFromSelect = true;

  //Para la seleccion de ruta
  String hacia;
  LatLng toLatLng;


  // google places
  places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(apiKey: Entorno.API_KEY_MAPS);


  //contructor //instanciarlo
  Future init(BuildContext context ,Function refresh)async
  {
    markerDriver = await createMarketImageFromAsset('assets/img/pointavalable.png');
    this.context = context;
    this.refresh = refresh;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _driverProvider = new DriverProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere...');
    checkGPS();
    saveToken();
    getClientInfo();
    
  }
  //traemos la info del conductor de la base de datos
void signOut ()async
{

  await _authProvider.signOut();
  Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
}
void getClientInfo ()
{
  Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser().uid);
   _clientSuscription = clientStream.listen((DocumentSnapshot document) { 
    client = Client.fromJson(document.data());
    refresh();  
   });
}
void dispose ()
{
  _positionStream?.cancel();
  _statusSuscription?.cancel();
  _clientSuscription?.cancel();
}
  void onMapCreate(GoogleMapController controller)
  {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
 }

//guarda informacion sobre la ubicacion del conductor



//Botones para Conectarse o Desconectarse



  void updateLocation () async 
  {
   try{
    await _determinePosition();
    //obtiene la ultima posicion que usamos
    _position = await Geolocator.getLastKnownPosition(); //Obtener nuestra posicion una unica vez 
    centerPosition();
    getNearbyDrivers();
   }
   catch(error)
   {
     print('error al localizar $error' );
   }

  }
  //cambiar destino

  void changeFromTo()
  {
    //si esta seleccionado la ruta lo niega o acepta
    isFromSelect = !isFromSelect;
  if (isFromSelect) {
    utils.Snackbar.showSnackbar(context, key, 'Ha seleccionado el lugar de recojida');
  }
  else{
    utils.Snackbar.showSnackbar(context, key, 'Ha seleccionado el lugar de destino');
  }
    
  }

Future<Null> showGoogleAuto (bool isFrom)async
{
 places.Prediction p = await PlacesAutocomplete.show(context: context, 
 apiKey: Entorno.API_KEY_MAPS,
 language: 'es',
 strictbounds: true,
 radius: 3000,
 location: places.Location(20.4632885 , -97.7033273)
 );
 
 if (p != null) {
   places.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId, language: 'es');
   double lat = detail.result.geometry.location.lat;
   double lng = detail.result.geometry.location.lng;
   List<Address> address = await Geocoder.local.findAddressesFromQuery(p.description);
   if (address != null) {
   if (address.length > 0 ) {
     if (detail != null) {
       String direccion = detail.result.name;
       String city = address[0].locality;
       String departament = address[0].adminArea;
         if (isFrom) {
              from = '$direccion, $city, $departament';
              fromLatLng = new LatLng(lat, lng);
              
         }
         else{
              hacia = '$direccion, $city, $departament';
              toLatLng = new LatLng(lat, lng);
         }

         refresh ();
     } 
    }
   }
 }
}
//obtiene la ubicacion al estar selecionando en la pantalla
 Future<Null> setLocationDraggableInfo () async
 {
    if (initialPosicion != null) {
        double lat = initialPosicion.target.latitude;
        double lhg = initialPosicion.target.longitude;
      List<Placemark> address = await placemarkFromCoordinates(lat, lhg);

      if (address != null ) {
        if (address.length > 0) {
          String direction = address[0].thoroughfare;
          String street = address[0].subThoroughfare;
          String city = address[0].locality;
          String departament = address[0].administrativeArea;
          String country = address[0].country;
          if (isFromSelect) {
             from = '$direction #$street , $city, $departament';
          fromLatLng = new LatLng(lat, lhg);
          }
          else
          {
            hacia = '$direction #$street , $city, $departament';
            toLatLng = new LatLng(lat, lhg);

          }
          refresh();
        }
      }
    }
 }
 
 void saveToken()
 {
   _pushNotificationsProvider.saveToken(_authProvider.getUser().uid, 'client');
 }

  void getNearbyDrivers ()
  {
    Stream<List<DocumentSnapshot>> stream = _geoFireProvider.getNearbyDrivers(_position.latitude, _position.longitude, 5);

    stream.listen((List<DocumentSnapshot> documentList) {
        
        for(MarkerId m in markers.keys)
        {
          bool remove = true;
          //serian todos los conductoes donde estoy
          for (DocumentSnapshot d in documentList )
          {
                if (m.value == d.id) {
                  remove = false;
                }
          }

          if (remove) {
          markers.remove(m);
          return refresh();
        }
        }
        for (DocumentSnapshot d in documentList)
        {
          GeoPoint point  = d.data()['position']['geopoint'];
          addMarker(
          d.id, 
          point.latitude, 
          point.longitude, 
          'MotoTaxi Disponible',
           d.id,
            markerDriver);
        }
        refresh();
     });
  }
  void centerPosition ()
  {
    if (_position != null) {
      //centrar la camara donde estamos ubicados
      animateCameraToPosition(_position.latitude, _position.longitude);
    }
    else
    {
      utils.Snackbar.showSnackbar(context, key, 'Activa tu GPS para obtener tu Posicion y pueda Funciona correctamente la App');
    }
  }
 void checkGPS() async
 {
   //Pregutar si la localizacion esta activada
   bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
   if (isLocationEnabled) {
     print('GPS Activado');
     updateLocation();
     
   }
   else
   {
     print('GPS Desactivado');
     bool locationGPS  = await location.Location().requestService();
     if (locationGPS ) {
       print('GPS Se Activo');
       updateLocation();
    
     }
     
   }
 }
//GPS Posicion Exacta
 Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

  Future animateCameraToPosition(double latitude, double longitude) async{

   GoogleMapController controller  = await _mapController.future;
   if (controller != null) {
     controller.animateCamera(CameraUpdate.newCameraPosition(
       CameraPosition(
        bearing: 0,
        target: LatLng(latitude,longitude),
        zoom: 17
       )
     ));
   }

  }
  //crearemos un marcador personalizado GPS
  Future<BitmapDescriptor> createMarketImageFromAsset(String path) async
  {
     ImageConfiguration configuration = ImageConfiguration();
     //recibe el objeto configuraration y ademas assetname el path
     BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
     return bitmapDescriptor;
  }

  void addMarker(String markerID ,
   double lat ,
    double lng,
     String title, 
     String content,
     BitmapDescriptor iconMarker
     )
     {
      MarkerId id= MarkerId(markerID);
      Marker marker = Marker
      (markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
      //realizar el marcador GPS mas dinamico
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5,0.5),
      rotation: _position.heading
      );
      markers[id] = marker;
      
     }

     //Boton para Ir a la Siguiente pantalla

     void goToViaje()
     {
       if (fromLatLng != null && toLatLng != null) {
          Navigator.pushNamed(context, 'client/viaje/info', arguments: {
            'from': from,
            'to': hacia,
            'fromLatLng': fromLatLng,
            'toLatLng': toLatLng,
          });
       }
       else
       {
         utils.Snackbar.showSnackbar(context, key, 'Debe Seleccionar el Lugar de Recogida y el Destino');
       }
        
     }
    
  //abrir el drawer

  void openDrawer()
  {
    key.currentState.openDrawer();
  }
}