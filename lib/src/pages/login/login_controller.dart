import 'package:flutter/material.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:mototravel/src/models/driver.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/shared_pref.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mototravel/src/utils/snackbar.dart' as utils;

class loginController
{

// inicializamos el context el cual esto es nuestro construcctor
  BuildContext context;
   GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  // con esto permitimos y obtener los datos que escriba el cliente
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  //Instancias de las clases o Metodos
   AuthProvider _authProvider;
   ProgressDialog  _progressDialog;
   DriverProvider _driverProvider;
   ClientProvider _clientProvider;
   SharedPref _sharedPref;
   String _typeUser;
   //inicializacion 
  Future init (BuildContext context) async
  {
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _clientProvider = new ClientProvider(); 
    _progressDialog  = MyProgressDialog.createProgressDialog(context, 'Iniciando Sesion');
    _sharedPref = new SharedPref();
    _typeUser = await _sharedPref.read('typeUser');
  }
  //verifica que tipo de usuario es para llevarlo a la pagina correspondiente
   void goToRegisterPage()
   {

     if (_typeUser == 'client') {
         //enviamos a otra pagina dentro de nuestra app
       Navigator.pushNamed(context, 'client/register');
     } else {

       Navigator.pushNamed(context, 'driver/register');
     }

     
   }
   //realiza la validacion de inicio de sesion
  void login()
   async{
      String email = emailController.text.trim();
      String password =  passController.text.trim();

      print('Email: $email');
      print('pass: $password');
       
       //Si el usuario no ingresa nada la accion termina
       if (email.isEmpty && password.isEmpty) {
         utils.Snackbar.showSnackbar(context, key ,'Los Campos no Pueden Ser Vacios');
         return;
       }
       //si la contraseña esta vacia no realizara nada
       if (password.isEmpty) {
         utils.Snackbar.showSnackbar(context, key ,'La Contraseña no Puede ir vacia');
          return;
       }

        if (password.length <= 6) {
         utils.Snackbar.showSnackbar(context, key ,'La Contraseña es deficiente');
          return;
       }
       _progressDialog.show();
  try
  {
    bool isLogin = await _authProvider.login(email, password);
   
    if (isLogin)
    {
       if (_typeUser == 'client'){
         Client client = await _clientProvider.getById(_authProvider.getUser().uid);

         if (client != null) {
           Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
         }

        else{
        utils.Snackbar.showSnackbar(context, key ,'El Acceso no es valido intente de nuevo');
        await _authProvider.signOut();
        }

       }

        else if (_typeUser == 'driver'){
         Drive drive = await _driverProvider.getById(_authProvider.getUser().uid);

         if (drive != null) {
           Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
         }

        else{
        utils.Snackbar.showSnackbar(context, key ,'El Acceso no es valido intente de nuevo');
        await _authProvider.signOut();
        }
        
       }

    }
    else
    {
       utils.Snackbar.showSnackbar(context, key ,'Creo que la Cuenta que ingresaste no existe intentalo otra vex');
       print('Hijole yo creo que no se va a poder');
    }
  }
  catch (error)
  {
      Future.delayed(Duration(milliseconds: 2000), (){
          _progressDialog.hide();
       });
     utils.Snackbar.showSnackbar(context, key ,'¡Upps! no encontramos ningun registro con la cuenta que ingresaste');
    return;
  }
  }
   
}