import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mototravel/src/pages/login/login_controller.dart';
import 'package:mototravel/src/utils/colors.dart' as utils;
import 'package:mototravel/src/widgets/button_app.dart';
import 'package:flutter/scheduler.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {  

  loginController _con = new loginController();


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
               backgroundColor: utils.Colors.motocolorMint
      ),
      body: SingleChildScrollView(
        child: Column (
          children: [
            _clipshow(),
            _textDesc(),
            _textP(),
            _log1(),
             SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _textF(),
            _textPassword(),
            _buttonL(),
            _textDown(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _textsublime()
          ]
        ),
      ),
    );
  }
  //Start Widget Labels 
  Widget _textDesc()
  {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 25 , vertical: 10),
      child: Text('¡Bienvenido! de Nuevo',
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
       child: Text('Inicia Sesion',
        style: TextStyle (
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
       )

    );
  }

    Widget _log1()
  {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 25 , vertical: 10),
      child: Text('Para Continuar',
      style: TextStyle(color: Colors  .black54,
      fontSize: 17,
      fontFamily: 'Fuente'
      )
      
      ),
    );
  }

  //End Widgets Label
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
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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




  Widget _clipshow()
  {
       return
           ClipPath(
                  clipper: WaveClipperOne(),
                  child:   Container(
                    color: utils.Colors.motocolorMint,
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

  Widget _buttonL ()
  {
   
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: buttonApp(
      onPresed: _con.login,
      text: 'Inicia Sesion',
      color: utils.Colors.motocolorMint,
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

  Widget _textDown ()
  {
    return GestureDetector(
      onTap: _con.goToRegisterPage,
      child: Container(
        
        child: Text('¿No Tienes Cuenta?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black
          ),      
        ),
      ),
    );
  }

  Widget _textsublime ()
  {
    return Container(
      child: Text('MotoTravel Ver 1.0',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black
        ),      
      ),
    );
  }
}