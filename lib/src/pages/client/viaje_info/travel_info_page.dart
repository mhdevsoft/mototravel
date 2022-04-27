import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/pages/client/viaje_info/tavel_info_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:mototravel/src/utils/colors.dart' as theme;

class ClientTravelInfoPage extends StatefulWidget {

  @override
  _ClientTravelInfoPageState createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {
 ClienteInfoController _con = new ClienteInfoController();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {_con.init(context,refresh);});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
     body: Stack(
     children: [
       Align(
         child: _googleMapsWidget(),
         alignment: Alignment.topCenter,
        ),
        Align(child: _cardViajeInfo(),
        alignment: Alignment.bottomCenter,
        ),
        Align(child: _backButton(),
        alignment: Alignment.topLeft,),
        Align(child: _cardKMInfo(_con.km),
        alignment: Alignment.topRight,),
         Align(child: _timeInfo(_con.min),
        alignment: Alignment.topRight,)
     ],
     ),
    );
  }
  //Kilometros
  Widget _cardKMInfo(String km)
  {
    return SafeArea(child: Container(
      width: 110,
    padding: EdgeInsets.symmetric(horizontal: 30),
    margin: EdgeInsets.only(right: 10 ,top: 10),
    decoration: BoxDecoration(
      color: Colors.amber,
      borderRadius: BorderRadius.all(Radius.circular(20))
    ),
     child: Text(km ?? '', maxLines: 1,),
    ));
  }
  
  Widget _timeInfo(String min)
  {
    return SafeArea(child: Container(
      width: 110,
    padding: EdgeInsets.symmetric(horizontal: 30),
    margin: EdgeInsets.only(right: 10 ,top: 35),
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.all(Radius.circular(20))
    ),
     child: Text(min ?? '', maxLines: 1),
    ));
  }
  Widget _backButton ()
  {
    return SafeArea(
      child: Container (
      margin: EdgeInsets.only(left: 10, top: 5),
      child: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: Icon(Icons.arrow_back, color: Colors.black,),
      
      ),),
    );
  }


  Widget _cardViajeInfo ()
  {
    return Container(
      height: MediaQuery.of(context).size.height*0.39,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        //establecemos bordes solo en las partes superiores
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
      ),
      child: Column(children: [
      ListTile(
        title: Text('Desde', style: TextStyle(fontSize: 15),),
        subtitle: Text(_con.from ?? '' , style: TextStyle(fontSize: 13),),
        leading: Icon(Icons.location_on),
      ),
       ListTile(
        title: Text('Hacia', style: TextStyle(fontSize: 15),),
        subtitle: Text(_con.to ?? '' , style: TextStyle(fontSize: 13),),
        leading: Icon(Icons.my_location),
      ),
       ListTile(
        title: Text('Total Estiamdo', style: TextStyle(fontSize: 15),),
        subtitle: Text('${_con.minTotal ?? '10.0'}\$ - ${_con.maxTotal ?? '15.0'}\$' , style: TextStyle(fontSize: 13),),
        leading: Icon(Icons.attach_money),
      ),
      Container(
      margin: EdgeInsets.symmetric(horizontal: 30),  
      child: buttonApp(onPresed: _con.goToSolicitar,
      text: 'INICIAR VIAJE',
      textApp: Colors.white,
      color: theme.Colors.motoappColor,
      icon: Icons.hail,
      ),)
      ],),
    );

  }

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