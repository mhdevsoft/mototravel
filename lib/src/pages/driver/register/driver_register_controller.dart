import 'package:flutter/material.dart';
import 'package:mototravel/main.dart';
import 'package:mototravel/src/models/driver.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';

class DriverregisterController
{

// inicializamos el context el cual esto es nuestro construcctor
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  // con esto permitimos y obtener los datos que escriba el cliente
  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
  //Text OTP Controller
  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller = new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();
   AuthProvider _authProvider;
   DriverProvider _driverProvider;
   ProgressDialog  _progressDialog;
    //inicializacion 
  Future init (BuildContext context)
  {
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog  = MyProgressDialog.createProgressDialog(context, 'Creando tu Cuenta e Iniciando Sesion Por Primera Vez');
  }

  void register ()async
  {
     String username =  usernameController.text;
      String email = emailController.text.trim();
      String password =  passController.text.trim();
      String passwordverify = confirmController.text.trim();
      //Capturar los datos de la placa

      String pin1 = pin1Controller.text.trim();
      String pin2 = pin2Controller.text.trim();
      String pin3 = pin3Controller.text.trim();
      String pin4 = pin4Controller.text.trim();
      String pin5 = pin5Controller.text.trim();
      String pin6 = pin6Controller.text.trim();
      
      String placa = '$pin1$pin2$pin3 - $pin4$pin5$pin6';

   if (username.isEmpty && email.isEmpty && password.isEmpty & passwordverify.isEmpty)
   {
     utils.Snackbar.showSnackbar(context, key ,'Los Campos Estan Vacios');
     print('no hay datos');
     return;
   }
   if (passwordverify != password) {
      utils.Snackbar.showSnackbar(context, key ,'La Contraseñas no Coinciden');
     print('contraseñas incorrectas');
     return;
   }
   if (password.length < 6) {
      utils.Snackbar.showSnackbar(context, key ,'Tu Nueva contraseña debe tener almenos 8 caracteres');
     print('contraseña con logitun minima');
     return;
   }
  _progressDialog.show();
  try
  {
    bool isRegister = await _authProvider.register(email, password);

    if (isRegister)
    {
     
      Drive driver = new Drive(
      id:  _authProvider.getUser().uid,
      email: _authProvider.getUser().email,
      username: username,
      password: password,
      placa: placa


     );
      await _driverProvider.create(driver);
      _progressDialog.hide();
      Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
      print('Que Pro');

    }
    else
    {
       _progressDialog.hide();
       utils.Snackbar.showSnackbar(context, key ,'Upps Creo que sucedio Algo Porfavor intentalo de nuevo');
       print('Hijole yo creo que no se va a poder');
    }
  }
  catch (error)
  {
     _progressDialog.hide();
  print('error $error');
  }
    
  }
   
}