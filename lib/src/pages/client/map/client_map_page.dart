import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mototravel/src/pages/client/map/client_map_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:mototravel/src/utils/colors.dart' as theme;
class ClientMapPage extends StatefulWidget {


  @override
  _ClientMapPageState createState() => _ClientMapPageState(); 
 
}

class _ClientMapPageState extends State<ClientMapPage> {
  ClientMapController _con = new ClientMapController();
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
              _buttonDrawer(),
              _googleCard(),
              _buttonHacia(),
              _buttonGPS(),
             Expanded(child: Container()),
             _buttonRequest()
           ],
         ),
       ),
       Align(
         alignment: Alignment.center,
         child: _iconMyLocation(),)
       ],
     )

    );
  }
  //Google Card
  Widget _googleCard ()
  {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      child: Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
       child: Container(
         padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
         child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           //google card
         _infoDestino('desde', _con.from ?? '', ()async {await _con.showGoogleAuto(true);}
         ),
         SizedBox(height: 5,),
        Container(child: Divider(color: Colors.grey,)
        ),
        //google card
        _infoDestino('Hacia', _con.hacia ?? '', ()async {await _con.showGoogleAuto(false);})
        ],)
        
        ,),
        ),
    );
  
  }

  //Google Card
   Widget _infoDestino (String title, String value, Function function)
   {
     return GestureDetector(
       onTap: function,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, 
          style: TextStyle(color:  Colors.grey,
            fontSize: 10),
          ),
            Text(value, 
          style: TextStyle(color:  Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            ),
             maxLines: 2,
          ),
         ],
       ),
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
             CircleAvatar(
               backgroundImage: AssetImage('assets/img/user.png'),
               radius: 35,
                   
             ),
             SizedBox(height: 10,),
               Container(
             child: Text(_con.client?.username ?? '', 
             style: TextStyle(fontSize: 18 ,
             color: Colors.white,
             fontWeight: FontWeight.bold
             ),
             maxLines: 1,
             ),
             ),
                 Container(
             child: Text(_con.client?.email ?? '',
             style: TextStyle(fontSize: 14 ,
             color: Colors.white,
             fontWeight: FontWeight.bold
             ),
             maxLines: 1,
             ),
             ),
           ],
         ),
         decoration: BoxDecoration(
           color: theme.Colors.motocolorMint
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
Widget _iconMyLocation ()
{
  return Image.asset('assets/img/gpsuser.png',
  width: 65,
  height: 65,);
}
//
Widget _buttonGPS()
{
  //container ubicamos margenes y alineamientos
  return GestureDetector(
    onTap: _con.centerPosition,
    child: Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: 13),
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

//Recojer

Widget _buttonHacia()
{
  //container ubicamos margenes y alineamientos
  return GestureDetector(
    onTap: _con.changeFromTo,
    child: Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Card(
     shape: CircleBorder(),
     elevation: 4.0,
     child: Container(
       padding: EdgeInsets.all(10),
       child: Icon(
       Icons.refresh,
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

Widget _buttonRequest()
{
  return Container(
    height: 50,
    alignment: Alignment.bottomCenter,
    margin: EdgeInsets.symmetric(horizontal: 60,vertical: 30),
    child: buttonApp(
      onPresed:_con.goToViaje,
      text:'Solicitar',
      color: Colors.red,
      textApp: Colors.white,
      icon: Icons.check,
    ),
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
      onCameraMove: (position) {_con.initialPosicion = position;},
      onCameraIdle: ()async
      {
        await _con.setLocationDraggableInfo();
      }
      
      ,
    );
  }
  void refresh ()
  {
    setState(() {
      
    });

  }
}