import 'package:flutter/material.dart';
import 'package:mototravel/main.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/utils/loader_get.dart';
import 'package:mototravel/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog/progress_dialog.dart';

class ClientRegisterController
{

// inicializamos el context el cual esto es nuestro construcctor
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  // con esto permitimos y obtener los datos que escriba el cliente
  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
   AuthProvider _authProvider;
   ClientProvider _clientProvider;
   ProgressDialog  _progressDialog;
    //inicializacion 
  Future init (BuildContext context)
  {
    this.context = context;
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _progressDialog  = MyProgressDialog.createProgressDialog(context, 'Espere un Momento....');
  }

  void register ()
   async{
     String username =  usernameController.text;
      String email = emailController.text.trim();
      String password =  passController.text.trim();
      String passwordverify = confirmController.text.trim();

      print('Email: $email');
      print('pass: $password');

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
     
      Client client = new Client(
      id:  _authProvider.getUser().uid,
      email: _authProvider.getUser().email,
      username: username,
      password: password,


     );
      await _clientProvider.create(client);
      _progressDialog.hide();
      utils.Snackbar.showSnackbar(context, key ,'¡Que Chido! Ahora inicia sesion con tu cuenta para continuar');
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