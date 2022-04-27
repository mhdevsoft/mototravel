import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:lottie/lottie.dart';
import 'package:mototravel/src/pages/client/travel_request/client_request_controller.dart';
import 'package:mototravel/src/utils/colors.dart' as theme;
import 'package:mototravel/src/widgets/button_app.dart';

class ClientTravelRequestPage extends StatefulWidget {

  @override
  _ClientTravelRequestPageState createState() => _ClientTravelRequestPageState();
}

class _ClientTravelRequestPageState extends State<ClientTravelRequestPage> {
  //Instanciamos nuestra clase 
  TravelClientRequest _con = new  TravelClientRequest();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {_con.init(context,refresh);});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.disponse();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      body: Column(children:[
       _driverInfo(),
       _lottieAnimation(),
       _textSearch(),
       _textCounter(),
       _textFound()
      
      ],
      ),
    bottomNavigationBar: _buttonClose(),
    );
  }

 Widget _lottieAnimation ()
 {
   return Lottie.asset('assets/json/delivery-motorbike.json',
   width: MediaQuery.of(context).size.width * 0.75,
   height: MediaQuery.of(context).size.height * 0.30,
   fit: BoxFit.fill
   );
 }


 Widget _textSearch ()
{
  return Container
  (
    margin:  EdgeInsets.symmetric(vertical: 10),
    child: Text('Buscando Mototaxi', style: TextStyle(fontSize: 17),)
  );
}

Widget _buttonClose ()
{
  return Container(
    height: 50,
    margin: EdgeInsets.all(30),
    child: buttonApp(text: 'Cancelar Viaje', icon: Icons.cancel, color: Colors.red, textApp:Colors.white)
  );
}

Widget _textCounter ()
{
  return Container(child: Text('0', style:TextStyle(fontSize: 40),),);
}

Widget _textFound ()
{
  return Container(child: Text('Encontrados', style:TextStyle(fontSize: 15),),);
}
  Widget _driverInfo()
  {
    //diseños de curvatura
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        color: theme.Colors.motoappSearch,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.33,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
        children: [ CircleAvatar(
           radius: 50,
           backgroundImage:AssetImage('assets/img/found.png',),
         ),
         Container(
           margin: EdgeInsets.symmetric(vertical: 10),
           child: Text('Tu Conductor',maxLines: 1,
           style: TextStyle(fontSize: 18, color: Colors.white),),
         ),
         ],
       ),
      ),
    );
  }
  void refresh ()
  {
    setState((){});
  }
}