import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:mototravel/src/api/enviroment.dart';
import 'package:mototravel/src/models/TravelHistory.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:mototravel/src/models/costos.dart';
import 'package:mototravel/src/models/travel_info.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/pages/providers/geofider_providers.dart';
import 'package:mototravel/src/pages/providers/precios_providers.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/pages/providers/travel_history_provider.dart';
import 'package:mototravel/src/pages/providers/travel_info_providers.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/colors.dart' as color;
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:mototravel/src/widgets/bottom_sheet_driver_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mototravel/src/models/driver.dart';


class DriverTravelMapController {
BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key  = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  //Object
  CameraPosition initialPosicion = CameraPosition(target: LatLng(20.4629037,-97.7017422),
  zoom: 14.0
  ) ;
    //Propiedades y Variables Globales
    Map <MarkerId,Marker> markers = <MarkerId, Marker>{};
    Position _position;
    StreamSubscription<Position> _positionStream;
    BitmapDescriptor markerDriver;
    BitmapDescriptor fromMarker;
    BitmapDescriptor toMarker;
    GeoFireProvider _geoFireProvider;
    AuthProvider _authProvider;
    DriverProvider _driverProvider;
    TravelInfoProvider _travelInfoProvider;
    CostosProviders _costosProviders;
    ClientProvider _clientProvider;
    TravelHistoryProvider _travelHistoryProvider;
    PushNotificationsProvider _pushNotificationsProvider;
    bool isConnect = false;
    ProgressDialog _progressDialog;
  
    
  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverSuscription;
  Set <Polyline> polylines = {};
  List <LatLng> points = new List();  

    //Imagenes PNG

  
  //modelo JSON
  Drive driver;
  Client client;

  String _idTravel;
  TravelInfo travelInfo;
  String current = 'INICIAR VIAJE';
  Color state = Colors.amber;
  double _distanceBetween;

  Timer _timer;
  int seconds = 0 ;
  double mt = 0;
  double km = 0;
  //contructor //instanciarlo
  Future init(BuildContext context ,Function refresh)async
  {
   
    this.context = context;
    this.refresh = refresh;
    //capturando ID que estamos necesitando
    _idTravel = ModalRoute.of(context).settings.arguments as String;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _costosProviders = new CostosProviders();
    _clientProvider = new ClientProvider();
    _travelHistoryProvider = new TravelHistoryProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere...');
     markerDriver = await createMarketImageFromAsset('assets/img/point.png');
    fromMarker = await createMarketImageFromAsset('assets/img/start.png');
    toMarker = await createMarketImageFromAsset('assets/img/b.png');
    checkGPS();
    getDriverInfo();
  }

 void getClientInfo() async
 {
   client = await _clientProvider.getById(_idTravel);
 }
 //muestra la infomracion al cliente / conductor 
  void openBottomSheet()
  {
    if (client == null) return;
     showModalBottomSheet(context: context, builder: (context) => BottomSheetDriverInfo(
      imageUrl: '',
      username: client?.username,
      email: client?.email,
      telefono: 'Sin Numero',
    ));
  }

//calculamos el costo durante el viaje por los KM y Min recorridos
Future<double>  calcularPrecio() async
{
 Costos costos = await _costosProviders.getAll();

 if (seconds < 60) seconds = 60; 
 if (km == 0) km = 1; 
 
 int min = seconds ~/ 60;

 print('------MIN TOTALES-------');
 print(min.toString());

  print('------KM TOTALES-------');
  print(km.toString());

 double precioMin = min * costos.min;
 double precioKM = km * costos.km;

 double total  = precioMin + precioMin; 

 if (total < costos.minValue)
 {
   total = costos.minValue;
 }
 return total;
}

//realiza el conteo de los segundos transcurridos del viaje
void startTimer()
{
 _timer = Timer.periodic(Duration(seconds: 1), (timer) {
   seconds = timer.tick;
   refresh();
  });
}


void isCloseToPickup(LatLng from , LatLng to)
{
  //medimos la distancia entre un punto a otro
 _distanceBetween = Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude);
  print('------ DISTANCE: $_distanceBetween--------');
}

//cambio de los estados del viaje por parte del conductor
void updateStatus()
  {
    if(travelInfo.status == 'accepted')
    {
      startTravel();
    }
     else if(travelInfo.status == 'started')
    {
      finishTravel();
      
    }
  }
//actualizando viajes
void startTravel() async
{
  //validamos si el conductor esta cerca del cliente para actializar viaje
   if (_distanceBetween <= 1000) {
      Map<String, dynamic> data = {
        'status': 'started'
      };
await _travelInfoProvider.update(data, _idTravel);
travelInfo.status = 'started';
current = 'FINALIZAR VIAJE';
state = Colors.cyan;

//elimina el trazado de busqueda al cliente para crear otra del viaje
polylines = {};
points = List();
markers.removeWhere((key, marker) => marker.markerId.value == 'from');

//trazamos la nueva ruta donde se llevara al cliente
addMarker('to', travelInfo.toLat, travelInfo.toLhg, 'Destino', '', toMarker);

LatLng from = new LatLng(_position.latitude, _position.longitude);
LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLhg);

setPolyLines(from, to);
startTimer();
refresh();
 }
else
{
  utils.Snackbar.showSnackbar(context, key, 'Aun no puedes iniciar el viaje debes estar cerca del lugar de recogida del cliente');
}
refresh();
}
//
void finishTravel() async
{
_timer?.cancel();
 Map<String, dynamic> data = {
      'status': 'finished'
    };
    await _travelInfoProvider.update(data, _idTravel);
    travelInfo.status = 'finished';
//Map<String, dynamic> data = {
//  'status': 'finished',
//};
//double total = await calcularPrecio();
saveTravelHistory();
}

void saveTravelHistory() async
{
TravelHistory travelHistory = new TravelHistory(
  from: travelInfo.from,
  to: travelInfo.to,
  idDriver: _authProvider.getUser().uid,
  idClient: _idTravel,
  timestamp: DateTime.now().millisecondsSinceEpoch,

);
String id = await _travelHistoryProvider.create(travelHistory);
Navigator.pushNamedAndRemoveUntil(context,'driver/travel/calification',(route) => false, arguments: id);
}

void _getTravelInfo() async
{
 travelInfo = await _travelInfoProvider.getById(_idTravel);
 //from desde donde se va a trazar la ruta la cual sera mi posicion
 LatLng from = new LatLng(_position.latitude, _position.longitude);
 LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLhg);;
 addMarker('from', to.latitude, to.longitude, 'Cliente por Recojer', '', fromMarker);
 setPolyLines(from, to);
 getClientInfo();
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

  Polyline polyline  = Polyline(polylineId: PolylineId('poly'),color: Colors.green,points: points, width: 6);

  polylines.add(polyline);
  
  refresh();  
}


void getDriverInfo()
{
  Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser().uid);
   _driverSuscription = driverStream.listen((DocumentSnapshot document) { 
    driver = Drive.fromJson(document.data());
    refresh();  
   });
}
void dispose()
{
  _timer?.cancel();
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
    await _geoFireProvider.createSet(_authProvider.getUser().uid,
     _position.latitude,
    _position.longitude);
    _progressDialog.hide();
  }

//Botones para Conectarse o Desconectarse



  void updateLocation() async 
  {
   try{
    await _determinePosition();
    //obtiene la ultima posicion que usamos
    _position = await Geolocator.getLastKnownPosition();
    _getTravelInfo();
    centerPosition();
    saveLocation();
    addMarker('driver', _position.latitude, _position.longitude, 'Tu Posicion', 'content', markerDriver);
     refresh();
    _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best,distanceFilter: 1).listen((Position position) 
    
    { 
      if (travelInfo?.status == 'started') {
        mt = mt + Geolocator.distanceBetween(_position.latitude, _position.longitude , position.latitude, position.longitude);
        km = mt / 1000;
        print('---------KM--------');
      }
     //logica para actualizar en tiempo real la ubicacion //Listen esto se estara en constante acualizando
        _position = position;
        addMarker('driver', _position.latitude, _position.longitude, 'Tu Posicion', '', markerDriver);
        animateCameraToPosition(_position.latitude, _position.longitude); 
        if (travelInfo.fromLat != null && travelInfo.fromLhg != null) {
          //posicion actualual del conduto
          LatLng from = new LatLng(_position.latitude, _position.longitude);
          //posicion del cliente
          LatLng to = new LatLng(travelInfo.fromLat, travelInfo.toLhg);
          // lo almacenamos en el metodo y lo calculamos
          isCloseToPickup(from, to);
        }
         saveLocation();
         refresh();
    });
   }
   catch(error)
   {
     print('error al localizar $error' );
   }

  }

  void centerPosition()
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
     // draggable: false,
     // zIndex: 2,
     // flat: true,
     // anchor: Offset(0.5,0.5),
     // rotation: _position.heading
      );


      
      markers[id] = marker;
      
     }


}