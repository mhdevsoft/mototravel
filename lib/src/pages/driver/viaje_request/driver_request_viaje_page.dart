import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mototravel/src/pages/driver/viaje_request/driver_request_viaje_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:mototravel/src/utils/colors.dart' as utils;
class DriverlTravelRequestPage extends StatefulWidget {


  @override
  _DriverlTravelRequestPageState createState() => _DriverlTravelRequestPageState();
}

class _DriverlTravelRequestPageState extends State<DriverlTravelRequestPage> {
  DriverTravelController _con = new DriverTravelController();
   
   @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }

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
      body: Column(
        children: [
        _informacionCliente(),
        _informacionViaje(_con.from ?? '', _con.to ?? ''),
        _timeStep()
        ],
      ),
      bottomNavigationBar: _buttonAct(),
    );
  }
 
 Widget _informacionViaje(String from, String to)
 {
   return Expanded(
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisAlignment: MainAxisAlignment.center,
     children: [
       Text('Recojer en:', style: TextStyle(fontSize: 20, color: Colors.black),),
       Container(
         margin: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
         child: Text(from, style: TextStyle(fontSize: 16, color: Colors.black),
          maxLines: 2,
          )
        ),
        SizedBox(height: 20,),
        Text('Llevarlo a:', style: TextStyle(fontSize: 20, color: Colors.black),),
       Container(
         margin: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
         child: Text(to, style: TextStyle(fontSize: 16, color: Colors.black),
          maxLines: 2,
          )
        )
     ],
     ),
   );
 }
 
 Widget _buttonAct()
 {
   return Container(
     height: 50,
     margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
     width: double.infinity,
     child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     children: [
       Container(
         width: MediaQuery.of(context).size.width * 0.44,
         child: buttonApp(text: 'Cancelar', onPresed: _con.cancelTravel, color: Colors.red, textApp: Colors.white , icon: Icons.cancel),
       ),
       Container(
         width: MediaQuery.of(context).size.width * 0.44,
         child: buttonApp(text: 'Aceptar', onPresed: _con.acceptViaje, color: utils.Colors.motoappSearch, textApp: Colors.white , icon: Icons.check),
       )
     ],
     ),
   );
 } 

  Widget _timeStep()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text(_con.seconds.toString(),
      style: TextStyle(fontSize: 25 , color: Colors.black),
      ),
    );
  }


  Widget _informacionCliente()
  {
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container (
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        color: utils.Colors.motorequest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50,backgroundColor: Colors.transparent , backgroundImage:AssetImage('assets/img/user.png'),),
           Container (
             margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
             child: Text(_con.client?.username ?? '', style: TextStyle(fontSize: 17, color: Colors.white),),
             ),
          ],
        ),
      )
    );
  }

void refresh()
{
  setState(() {
    
  });
}

}