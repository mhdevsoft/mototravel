import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/pages/client/travel_map/client_travel_map_controller.dart';
import 'package:flutter/scheduler.dart';

class ClientTravelMapPage extends StatefulWidget {
  @override
  _ClientTravelMapPageState createState() => _ClientTravelMapPageState();
}

class _ClientTravelMapPageState extends State<ClientTravelMapPage> {
   ClientTravelMapController _con = ClientTravelMapController();
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
       children: [ 
         _googleMapsWidget(),
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
                 _cardStatus(_con.current),
                 _buttonGPS(),
               ]),
              Expanded(child: Container()),
           ],
         ),
       ),

       ],
     )
    );
  }

Widget _cardStatus(String status)
{
  return SafeArea(
    child: Container(
      width: 110,
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.only(top: 10),
     decoration: BoxDecoration(
       color: _con.state,
       borderRadius: BorderRadius.all(Radius.circular(20))
     ),
     child: Text('${status ?? ''} Sin Ruta',
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
    onTap: (){},
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


 

//Mapa API 
  Widget _googleMapsWidget()
  {
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
