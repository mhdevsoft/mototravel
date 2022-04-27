import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/pages/driver/travel_map/driver_travel_map_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';

class DriverTravelMapPage extends StatefulWidget {

  @override
  _DriverTravelMapPageState createState() => _DriverTravelMapPageState();
}

class _DriverTravelMapPageState extends State<DriverTravelMapPage> {
 DriverTravelMapController _con = DriverTravelMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
     body: Stack (
       children: [ _googleMapsWidget(),
       //coloca elementos uno encima de otro
       //Safe Area respetara el margen de las noticiaciones o notch en telefonos
       SafeArea(
         child: Column(
           children: [
             Row(
               //expande los elementos hacia las esquinas
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 _buttonUser(),
                 Column(
                 children: [   
                   _cardKmInfo(_con.km?.toStringAsFixed(1)),
                   _cardTmInfo(_con.seconds?.toString()),
                   ],
                 ),
                 _buttonGPS()
               ],
             ),
             Expanded(child: Container()),
             _buttonStatus()
           ],
         ),
       )
       ],
     )
    );
  }

Widget _cardKmInfo(String km)
{
  return SafeArea(
    child: Container(
      width: 110,
      margin: EdgeInsets.only(top: 10),
     decoration: BoxDecoration(
       color: Colors.amber,
       borderRadius: BorderRadius.all(Radius.circular(20))
     ),
     child: Text('${km ?? ''} km',
     maxLines: 1,
     textAlign: TextAlign.center,
     ),
  ));
}

Widget _cardTmInfo(String min)
{
  return SafeArea(
    child: Container(
      width: 110,
      margin: EdgeInsets.only(top: 10),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.all(Radius.circular(20))
     ),
     child: Text('${min ?? ''} seg',
     maxLines: 1,
     textAlign: TextAlign.center,
     ),
  ));
}


//GPS Button
Widget _buttonUser()
{
  //container ubicamos margenes y alineamientos
  return GestureDetector(
    onTap: _con.openBottomSheet,
    child: Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Card(
     shape: CircleBorder(),
     elevation: 4.0,
     child: Container(
       padding: EdgeInsets.all(10),
       child: Icon(
       Icons.person,
       color: Colors.grey[600], 
       size: 20,),
     ),
  
    ),),
  );
}


//GPS Button
Widget _buttonGPS()
{
  //container ubicamos margenes y alineamientos
  return GestureDetector(
    onTap: _con.centerPosition,
    child: Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Card(
     shape: CircleBorder(),
     elevation: 4.0,
     child: Container(
       padding: EdgeInsets.all(10),
       child: Icon(
       Icons.location_searching,
       color: Colors.grey[600], 
       size: 20,),
     ),
  
    ),),
  );
}


//Boton Status

Widget _buttonStatus()
{
  return Container(
    height: 50,
    alignment: Alignment.bottomCenter,
    margin: EdgeInsets.symmetric(horizontal: 60,vertical: 30),
    child: buttonApp(
      onPresed: _con.updateStatus,
      text: _con.current,
      color: _con.state,
      textApp: Colors.white,
      icon: Icons.directions_bike,
    ),
  );
}
 

//Mapa API 
  Widget _googleMapsWidget()
  {
     setState(() {
       
     });
    return GoogleMap
    (
      
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosicion,
      //recibe una funcion de google maps
      onMapCreated: _con.onMapCreate,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }
  void refresh ()
  {
    setState(() {
      
    });

  }
}