import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/colors.dart' as color;
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mototravel/src/models/driver.dart';
class DriverMapController 
{
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key  = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  //Object
  CameraPosition initialPosicion = CameraPosition(target: LatLng(20.4629037,-97.7017422),
  zoom: 14.0
  ) ;
    //Propiedades y Variables Globales
    Position _position;
    StreamSubscription<Position> _positionStream;
    BitmapDescriptor markerDriver;
    GeoFireProvider _geoFireProvider;
    AuthProvider _authProvider;
    DriverProvider _driverProvider;
    PushNotificationsProvider _pushNotificationsProvider;
    bool isConnect = true;
    ProgressDialog _progressDialog;
    Map <MarkerId,Marker> markers = <MarkerId, Marker>{};
    
  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverSuscription;
  //modelo JSON
  Drive driver;
  //contructor //instanciarlo
  Future init(BuildContext context ,Function refresh)async
  {
    markerDriver = await createMarketImageFromAsset('assets/img/point.png');
    this.context = context;
    this.refresh = refresh;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere...');
    checkGPS();
    getDriverInfo();
    saveToken();
  }
  //traemos la info del conductor de la base de datos
void signOut ()async
{

  await _authProvider.signOut();
  Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
}
void getDriverInfo ()
{
  Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser().uid);
   _driverSuscription = driverStream.listen((DocumentSnapshot document) { 
    driver = Drive.fromJson(document.data());
    refresh();  
   });
}
void dispose ()
{
  _positionStream?.cancel();
  _statusSuscription?.cancel();
  _driverSuscription?.cancel();
}
  void onMapCreate(GoogleMapController controller)
  {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
 }

//guarda informacion sobre la ubicacion del conductor

  void saveLocation()async
  {
    await _geoFireProvider.create(_authProvider.getUser().uid,
     _position.latitude,
    _position.longitude);
    _progressDialog.hide();
  }

//Botones para Conectarse o Desconectarse

void connect ()
{
 if (isConnect) {
   disconect();
 }
 else{
   _progressDialog.show();
   updateLocation();
 }
}
void disconect ()
{
  //si viene diferente de nulo para detener y eliminar el metodo 
  //y por entonces no comenzaria a moverse
  //el ? sirve par asegurarnos que no venga nulo
 _positionStream?.cancel();
 _geoFireProvider.delete(_authProvider.getUser().uid);

}

void checkIfIsConnect()
{
  Stream<DocumentSnapshot> status = _geoFireProvider.getLocationByIdStream(_authProvider.getUser().uid);
 _statusSuscription = status.listen((DocumentSnapshot document) {
   if (document.exists) {
     isConnect = true;
   } else {
     isConnect = false;
   }
    refresh();
   }
   
   );
}


  void updateLocation () async 
  {
   try{
    await _determinePosition();
    //obtiene la ultima posicion que usamos
    _position = await Geolocator.getLastKnownPosition();
    centerPosition();
    saveLocation();
    addMarker('driver', _position.latitude, _position.longitude, 'Tu Posicion', 'content', markerDriver);
     refresh();
    _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best,distanceFilter: 1).listen((Position position) 
    
    { 
     //logica para actualizar en tiempo real la ubicacion //Listen esto se estara en constante acualizando
        _position = position;
        addMarker('driver', _position.latitude, _position.longitude, 'Tu Posicion', 'content', markerDriver);
        animateCameraToPosition(_position.latitude, _position.longitude); 
        saveLocation();
         refresh();
    });
   }
   catch(error)
   {
     print('error al localizar $error' );
   }

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
     checkIfIsConnect();
   }
   else
   {
     print('GPS Desactivado');
     bool locationGPS  = await location.Location().requestService();
     if (locationGPS ) {
       print('GPS Se Activo');
       updateLocation();
      checkIfIsConnect();
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

    void saveToken()
 {
   _pushNotificationsProvider.saveToken(_authProvider.getUser().uid, 'driver');
 }
  //abrir el drawer

  void openDrawer()
  {
    key.currentState.openDrawer();
  }
     
}