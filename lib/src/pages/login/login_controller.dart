import 'package:flutter/material.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
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
   AuthProvider _authProvider;
   ProgressDialog  _progressDialog;
   SharedPref _sharedPref;
   String _typeUser;
   //inicializacion 
  Future init (BuildContext context) async
  {
    this.context = context;
    _authProvider = new AuthProvider();
    _progressDialog  = MyProgressDialog.createProgressDialog(context, 'Iniciando Sesion');
    _sharedPref = new SharedPref();
    _typeUser = await _sharedPref.read('typeUser');
  }
   void goToRegisterPage()
   {

     if (_typeUser == 'client') {
         //enviamos a otra pagina dentro de nuestra app
       Navigator.pushNamed(context, 'client/register');
     } else {

       Navigator.pushNamed(context, 'driver/register');
     }

     
   }
  void login ()
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
       _progressDialog.show();
  try
  {
    bool isLogin = await _authProvider.login(email, password);
    if (isLogin)
    {
      _progressDialog.hide();
       utils.Snackbar.showSnackbar(context, key ,'Se Inicio Sesion Redireccionando');
      print('Que Pro');

    }
    else
    {
      _progressDialog.hide();
       utils.Snackbar.showSnackbar(context, key ,'Creo que la Cuenta que ingresaste no existe intentalo otra vex');
       print('Hijole yo creo que no se va a poder');
    }
  }
  catch (error)
  {
    
     utils.Snackbar.showSnackbar(context, key ,'¡Upps! no encontramos ningun registro con la cuenta que ingresaste');
    print('error $error');
    _progressDialog.hide();
  }
    
  }
   
}