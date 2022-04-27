import 'dart:async';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:mototravel/src/api/enviroment.dart';
import 'package:mototravel/src/models/travel_info.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/pages/providers/travel_info_providers.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/colors.dart' as color;
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:mototravel/src/widgets/bottom_sheet_client_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mototravel/src/models/driver.dart';


class ClientTravelMapController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key  = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  //Object
  CameraPosition initialPosicion = CameraPosition(target: LatLng(20.4629037,-97.7017422),zoom: 14.0 );
  Map <MarkerId,Marker> markers = <MarkerId, Marker>{};
    //Propiedades y Variables Globales
 
    BitmapDescriptor markerDriver;
    BitmapDescriptor fromMarker;
    BitmapDescriptor toMarker;
    GeoFireProvider _geoFireProvider;
    AuthProvider _authProvider;
    DriverProvider _driverProvider;
    TravelInfoProvider _travelInfoProvider;
    PushNotificationsProvider _pushNotificationsProvider;
    bool isConnect = false;
    ProgressDialog _progressDialog;

    
  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverSuscription;
  Set <Polyline> polylines = {};
  List <LatLng> points = new List();  


  //evitar trazado de rutas
  bool isRouteReady = false;
  String current = '';
  Color state = Colors.white;

  //modelo JSON
  Drive driver;
  LatLng _driverLatLng;
  TravelInfo travelInfo;
  // sentencias
  bool isPickup  = false;
  bool isTravelCheck = false;
  bool isFinishTravel = false;
  StreamSubscription<DocumentSnapshot> _streamLocationController;
  StreamSubscription<DocumentSnapshot> _streamTravelController;
  //contructor //instanciarlo
  Future init(BuildContext context ,Function refresh)async
  {

    this.context = context;
    this.refresh = refresh;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere...');
    markerDriver = await createMarketImageFromAsset('assets/img/point.png');
    fromMarker = await createMarketImageFromAsset('assets/img/start.png');
    toMarker = await createMarketImageFromAsset('assets/img/b.png');
    checkGPS();
  }

  void openBottomSheet()
  {
    if (driver == null) return;
    showModalBottomSheet(context: context, builder: (context) => BottomSheetClientInfo(
      imageUrl: '',
      username: driver?.username,
      email: driver?.email,
      placa: driver?.placa,
    ));
  }
  //accedemos a los datos del location para del conductor 
    void getDriverLocation(String idDriver)
    {
      Stream<DocumentSnapshot> stream = _geoFireProvider.getLocationByIdStream(idDriver);
     _streamLocationController = stream.listen((DocumentSnapshot document) { 
      GeoPoint geoPoint = document.data()['position']['geopoint'];
      _driverLatLng = new LatLng(geoPoint.latitude, geoPoint.longitude);
      addSimpleMarker('driver', _driverLatLng.latitude, _driverLatLng.longitude, 'Tu Conductor', 'content', markerDriver);
      refresh();
       //from desde donde se va a trazar la ruta la cual sera mi posicion
       if (!isRouteReady) {
      isRouteReady = true;
      checkTravelStatus();
       } 
    });
    }
//marcador donde se encuentra el cliente
 void pickupTravel()
 {
     if (!isPickup) {
      isPickup = true;
      LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLhg);
      addSimpleMarker('from', to.latitude, to.longitude, 'Cliente por Recojer', '', fromMarker);
      setPolyLines(from, to);
     }
  
 }

//cambia los estados de viaje
 void checkTravelStatus() async
{
  Stream<DocumentSnapshot>stream = _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
 _streamTravelController =  stream.listen((DocumentSnapshot document) {
    travelInfo = TravelInfo.fromJson(document.data());
 
    if (travelInfo.status == 'accepted') {
      current = '¡Viaje Aceptado!';
      state = Colors.cyan;
      pickupTravel();
    }
    else if (travelInfo.status == 'started')
    {
      current = '¡Empezo Viaje!';
      state = Colors.amber;
      startTravel();
    }
     else if (travelInfo.status == 'finished')
    {
      current = '¡Finalizado!';
      state = Colors.greenAccent[700];
      finishTravel();
    }

    refresh();
   });
}

void finishTravel()
  {
   if (!isFinishTravel) {
     isFinishTravel = true;
     Navigator.pushNamedAndRemoveUntil(context, 'client/travel/calification', (route) => false , arguments: travelInfo.idTravelHistory);
   }
  }

//inicia viaje
void startTravel()
{
 //verfica y cambia el estado de viaje
  if (!isTravelCheck) {
  isTravelCheck = true;
     //elimina el trazado de busqueda al cliente para crear otra del viaje
polylines = {};
points = List();
markers.removeWhere((key, marker) => marker.markerId.value == 'from ');

//trazamos la nueva ruta donde se llevara al cliente
addSimpleMarker('to', travelInfo.toLat, travelInfo.toLhg, 'Destino', 'content', toMarker);

LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLhg);

setPolyLines(from, to);
refresh();
}
 
}

//obtenemos la informacion de vijae 
void _getTravelInfo() async
{
 travelInfo = await _travelInfoProvider.getById(_authProvider.getUser().uid);
 animateCameraToPosition(travelInfo.fromLat, travelInfo.fromLhg);
 //obtenemos la informacion del conductor
 getDriverInfo(travelInfo.idDriver);
 getDriverLocation(travelInfo.idDriver);
}

//marcar la linea de inicio y final
Future<void> setPolyLines(LatLng from, LatLng to) async
{
  PointLatLng pointFromLatLhg = PointLatLng(from.latitude, from.longitude);
  PointLatLng pointToLatLhg = PointLatLng(to.latitude, to.longitude);

  PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
  Entorno.API_KEY_MAPS,
  pointFromLatLhg,
  pointToLatLhg
  );

  for (PointLatLng point in result.points) {
    points.add(LatLng(point.latitude, point.longitude));
  }

  Polyline polyline  = Polyline(polylineId: PolylineId('poly'),color: Colors.cyan,points: points, width: 6);

  polylines.add(polyline);

  refresh();  
}


//obtenemos la informacion del conductor de firebase
void getDriverInfo(String id) async
{
  driver = await _driverProvider.getById(id);
  refresh();
}
void dispose()
{

  _statusSuscription?.cancel();
  _driverSuscription?.cancel();
  _streamLocationController.cancel();
  _streamTravelController.cancel();
}
  void onMapCreate(GoogleMapController controller)
  {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
    _getTravelInfo();
 }


//Botones para Conectarse o Desconectarse
 void checkGPS() async
 {
   //Pregutar si la localizacion esta activada
   bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
   if (isLocationEnabled) {
     print('GPS Activado');

     
   }
   else
   {
     print('GPS Desactivado');
     bool locationGPS  = await location.Location().requestService();
     if (locationGPS ) {
       print('GPS Se Activo');
       
      
     }
     
   }
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

 void addSimpleMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ) {

    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
    );


      
      markers[id] = marker;
      
     }


}