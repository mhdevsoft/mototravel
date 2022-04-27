import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/api/enviroment.dart';
import 'package:mototravel/src/models/costos.dart';
import 'package:mototravel/src/models/directions.dart';
import 'package:mototravel/src/pages/providers/google_providers.dart';
import 'package:mototravel/src/pages/providers/precios_providers.dart';

class ClienteInfoController 
  {

  BuildContext context;
  Function refresh;
  GoogleProvider _googleprovider;
  CostosProviders _costosProviders;
  GlobalKey<ScaffoldState> key  = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  //Object
  CameraPosition initialPosicion = CameraPosition(target: LatLng(20.4629037,-97.7017422),
  zoom: 14.0
  );
  Map <MarkerId,Marker> markers = <MarkerId, Marker>{};
  
  //recibo indformacion 

  String from;
  String to;
  LatLng fromLatLhg;
  LatLng toLatLhg;

  double minTotal;
  double maxTotal;

  Set <Polyline> polylines = {};
  List <LatLng> points = new List();  

  //Imagenes PNG
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;

  Direction _directions;
  String min;
  String km;
//instancias 
    Future init (BuildContext context, Function refresh)async
  {
    this.context = context;
    this.refresh = refresh;
//capturamos los datos de la pantalla anterior
    Map<String, dynamic> argument = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    from = argument['from'];
    to = argument['to'];
    fromLatLhg = argument['fromLatLng'];
    toLatLhg= argument['toLatLng']; 
    _googleprovider = new GoogleProvider();
    _costosProviders = new CostosProviders();
    fromMarker = await createMarketImageFromAsset('assets/img/a.png');
    toMarker = await createMarketImageFromAsset('assets/img/b.png');
      getGoogleMaps(fromLatLhg,toLatLhg);
    animateCameraToPosition(fromLatLhg.latitude, fromLatLhg.longitude);
   
  }
  //calcularemos el precio y tiempo el cual se tendra en el viaje
void getGoogleMaps(LatLng from , LatLng to)async
{
  _directions = await _googleprovider.getGoogleDirection(from.latitude, from.longitude, to.latitude, to.longitude);
  min = _directions.duration.text;
  km = _directions.distance.text;
  calularPrecio();
  refresh();
}
//ir ala pantalla de solicitud e enviar los parametros de viaje
 void goToSolicitar()
 {
   Navigator.pushNamed(context, 'client/viaje/request', arguments: {
            'from': from,
            'to': to,
            'fromLatLng': fromLatLhg,
            'toLatLng': toLatLhg,
          });
 }
//calcula el precio dependiendo de las tarifas fijas
void calularPrecio()async
{
  //obtenemos de la base de datos los precios aproximados
  Costos costos = await _costosProviders.getAll();
  double kmValue = double.parse(km.split(" ")[0]) * costos.km;
  double minValue = double.parse(min.split(" ")[0]) * costos.min;
  double total = kmValue + minValue;
   minTotal = total - 15.0;
   maxTotal = total + 15.0;
   refresh();
}

//marcar la linea de inicio y final
Future<void> setPolyLines() async
{
  PointLatLng pointFromLatLhg = PointLatLng(fromLatLhg.latitude, fromLatLhg.longitude);
  PointLatLng pointToLatLhg = PointLatLng(toLatLhg.latitude, toLatLhg.longitude);

  PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
  Entorno.API_KEY_MAPS,
  pointFromLatLhg,
  pointToLatLhg
  );

  for (PointLatLng point in result.points) {
    points.add(LatLng(point.latitude, point.longitude));
  }

  Polyline polyline  = Polyline(polylineId: PolylineId('poly'),color: Colors.amber,points: points, width: 6);

  polylines.add(polyline);
  addMarker('from', fromLatLhg.latitude, fromLatLhg.longitude, 'Recoger Ahi', '', fromMarker);
  addMarker('to', toLatLhg.latitude, toLatLhg.longitude, 'Llegar Aqui', '', toMarker);
  refresh();  
}

  Future animateCameraToPosition(double latitude, double longitude) async{

   GoogleMapController controller  = await _mapController.future;
   if (controller != null) {
     controller.animateCamera(CameraUpdate.newCameraPosition(
       CameraPosition(
        bearing: 0,
        target: LatLng(latitude,longitude),
        zoom: 16
       )
     ));
   }

  }
     Future<BitmapDescriptor> createMarketImageFromAsset(String path) async
  {
     ImageConfiguration configuration = ImageConfiguration();
     //recibe el objeto configuraration y ademas assetname el path
     BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
     return bitmapDescriptor;
  }
  //agrega marcadores ala aplicacion de inicio y fin
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
      );
      markers[id] = marker;
      
     }
  //creacion de google maps API
   void onMapCreate(GoogleMapController controller) async
  {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
    await setPolyLines();
 }

 
  }