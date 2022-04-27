
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/pages/driver/map/driver_map_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:mototravel/src/utils/colors.dart' as theme;

class DriverMapPage extends StatefulWidget {


  @override
  _DriverMapPageState createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  DriverMapController _con = new DriverMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //inicializamos nuestro controlador
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {_con.init(context,refresh);});
  }

  @override
  //se ejecuta cuando cerramos la pantalla elimida datos para no generar basura
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      //llamamos nuestro drawer
      drawer: _drawer(),
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
                 _buttonDrawer(),
                 _buttonGPS()
               ],
             ),
             Expanded(child: Container()),
             _buttonConect()
           ],
         ),
       )
       
       
       
       ],
     )

    );
  }

  //Navigator Drawer
  Widget _drawer ()
  {
   return Drawer(
     //motrara elementos scroleables
     child: ListView(
       //Color Arriba
       padding: EdgeInsets.zero,
       children: [
         DrawerHeader(child: Column(
           //alineacion ala izquierda
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Container(
             child: Text(_con.driver?.username ?? '', 
             style: TextStyle(fontSize: 18 ,
             color: Colors.white,
             fontWeight: FontWeight.bold
             ),
             maxLines: 1,
             ),
             ),
                 Container(
             child: Text(_con.driver?.placa ?? '',
             style: TextStyle(fontSize: 14 ,
             color: Colors.white,
             fontWeight: FontWeight.bold
             ),
             maxLines: 1,
             ),
             ),
             SizedBox(height: 10,),
             CircleAvatar(
               backgroundImage: AssetImage('assets/img/user.png'),
               radius: 35,

             )
           ],
         ),
         decoration: BoxDecoration(
           color: theme.Colors.motodriver
         ),
         ),
          //
         ListTile(
          title: Text('Configuracion'),
          onTap: (){},
          trailing: Icon(Icons.settings),
         ),
          ListTile(
          title: Text('Cerrar Sesion'),
          onTap: _con.signOut,
          trailing: Icon(Icons.power_settings_new),
         ),
          ListTile(
          title: Text('Acerca de'),
          onTap: (){},
          trailing: Icon(Icons.info),
         ),
       ],
     ),


   );
  }
//GPS Button
Widget _buttonGPS()
{
  //container ubicamos margenes y alineamientos
  return GestureDetector(
    onTap: _con.centerPosition,
    child: Container(
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


//Menu Slider

Widget _buttonDrawer ()
{
return Container(
  
    alignment: Alignment.centerLeft,
    child: IconButton(onPressed: _con.openDrawer,
    icon: Icon(Icons.menu, color: Colors.white, ),
    ),
  
  );


}
//Boton Conect

Widget _buttonConect()
{
  return Container(
    height: 50,
    alignment: Alignment.bottomCenter,
    margin: EdgeInsets.symmetric(horizontal: 60,vertical: 30),
    child: buttonApp(
      onPresed: _con.connect,
      text:_con.isConnect?'Desconectarse': 'Conectarse',
      color: _con.isConnect? Colors.grey : Colors.green,
      textApp: Colors.white,
      icon: _con.isConnect? Icons.power_settings_new : Icons.directions_bike ,
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
    );
  }
  void refresh ()
  {
    setState(() {
      
    });

  }
}