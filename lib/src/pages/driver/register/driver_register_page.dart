import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mototravel/src/pages/driver/register/driver_register_controller.dart';
import 'package:mototravel/src/utils/colors.dart' as utils;
import 'package:mototravel/src/utils/otp_widget.dart';
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:flutter/scheduler.dart';


class DriverRegisterPage extends StatefulWidget {
   

  @override
  _DriverRegisterPage createState() => _DriverRegisterPage();
}

class _DriverRegisterPage extends State<DriverRegisterPage> {  

  DriverregisterController _con = new DriverregisterController();


 @override
 //nunca afectara al contruir el diseño
  void initState() {
    super.initState();
    //ejecutara despues del la costruccion del diseño
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      key: _con.key,
      appBar: AppBar(
               backgroundColor: utils.Colors.motoappColorDriver
      ),
      body: SingleChildScrollView(
        child: Column (
          children: [
            _clipshow(),
            _textDesc(),
            _textP(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
             _textPlaca(),
             //Ingreso de OTP Para Placa
             Container(
               margin: EdgeInsets.symmetric(horizontal: 25),
               child: OTPFields(pin1: _con.pin1Controller,
               pin2: _con.pin2Controller,
               pin3: _con.pin3Controller,
               pin4: _con.pin4Controller,
               pin5: _con.pin5Controller,
               pin6: _con.pin6Controller,
               ),
             ),
             _textU(),  
            _textF(),
            _textPassword(),
            _textPasswordVerify(),
            _buttonL(),
            _textsublime(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ]
        ),
      ),
    );
  }

//Wigets Contenedores por secciones

//Seecion texto Start
  Widget _textDesc()
  {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 25 , vertical: 10),
      child: Text('¡Trabaja con Nosotros!',
      style: TextStyle(color: Colors  .black54,
      fontSize: 20,
      fontFamily: 'Fuente'
      )
      
      ),
    );
  }

Widget _textP()
  {
    return Container(
       alignment: Alignment.centerLeft,
       margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0) ,
       child: Text('Registrate',
        style: TextStyle (
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
       )

    );
  }

  //Secccion Texto END

  //Seccion Cajas de texto Start
  Widget _textU ()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
         decoration: InputDecoration(
           labelStyle: TextStyle(color: Colors.black),
           focusColor: Colors.black,
          hintText: 'Juan Lopez Perez',
          labelText: 'Tu Nombre Completo',
           suffixIcon: Icon(
             Icons.person_outline,
             color: Colors.black,
           )
         ),
      ),
    );

  }

Widget _dateT()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
         decoration: InputDecoration(
           labelStyle: TextStyle(color: Colors.black),
           focusColor: Colors.black,
          hintText: 'Juan Lopez Perez',
          labelText: 'Tu Nombre Completo',
           suffixIcon: Icon(
             Icons.person_outline,
             color: Colors.black,
           )
         ),
      ),
    );

  }

  Widget _textF ()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
         decoration: InputDecoration(
           labelStyle: TextStyle(color: Colors.black),
           focusColor: Colors.black,
          hintText: 'Correo@gmail.com',
          labelText: 'Ingresa tu Correo',
           suffixIcon: Icon(
             Icons.email_outlined,
             color: Colors.black,
           )
         ),
      ),
    );

  }

  Widget _textPassword ()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.passController,
        obscureText: true,
         decoration: InputDecoration(
           labelStyle: TextStyle(color: Colors.black),
           focusColor: Colors.black,
          labelText: 'Contraseña',
           suffixIcon: Icon(
             Icons.lock_outline,
             color: Colors.black,
           )
         ),
      ),
    );

  }


  Widget _textPasswordVerify ()
  {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, ),
      child: TextField(
        controller: _con.confirmController,
        obscureText: true,
         decoration: InputDecoration(
           labelStyle: TextStyle(color: Colors.black),
           focusColor: Colors.black,
          labelText: 'Confirma tu Contraseña',
           suffixIcon: Icon(
             Icons.lock_outline,
             color: Colors.black,
           )
         ),
      ),
    );

  }

//Seccion Cajas de Texto END

//label and logos Start 
  
  Widget _clipshow()
  {
       return
           ClipPath(
                  clipper: WaveClipperOne(),
                  child:   Container(
                    color: utils.Colors.motoappColorDriver,
                    height: MediaQuery.of(context).size.height * 0.23,
                    child:Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Image.asset(
                      'assets/img/user.png',
                       width: 200,
                       height: 125,
                      ),
                  
                ],
              ),
                  ),
                );
  }

 Widget _textPlaca ()
 {
   return Container(
     alignment: Alignment.centerLeft,
     margin: EdgeInsets.symmetric(horizontal: 30 , vertical: 5),
     child: Text('Placa del Mototaxi Asignado',
     style: TextStyle (
       color: Colors.black,
       fontSize: 17
     ),
     ),
   );
 }
 

 //Boton

  Widget _buttonL ()
  {
   
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: buttonApp(
      onPresed: _con.register,
      text: 'Registrate',
      color: utils.Colors.motoappColorDriver,
      textApp: Colors.white
      ),
    );
   // Container(
     // width: double.infinity,
     // margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
     // child: RaisedButton(onPressed: (){},
      //child: Text ('Inicia Sesion',
      // style: TextStyle(
       //  color: Colors.white)
    //   ),
     // color: utils.Colors.motocolorLavander,
    //  ),
   // );
  }


  Widget _textsublime()
  {
    return Container(
      child: Text('MotoTravel Ver 1.0 Beta Release',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black
        ),      
      ),
    );
  }
}
//label and logo END
