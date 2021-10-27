import 'package:flutter/material.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';

class loginController
{

// inicializamos el context el cual esto es nuestro construcctor
  BuildContext context;
  // con esto permitimos y obtener los datos que escriba el cliente
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
   AuthProvider _authProvider;
   //inicializacion 
  Future init (BuildContext context)
  {
    this.context = context;
    _authProvider = new AuthProvider();
  }

  void login ()
   async{
      String email = emailController.text.trim();
      String password =  passController.text.trim();

      print('Email: $email');
      print('pass: $password');
  try
  {
    bool isLogin = await _authProvider.login(email, password);

    if (isLogin)
    {
      print('Que Pro');

    }
    else
    {
       print('Hijole yo creo que no se va a poder');
    }
  }
  catch (error)
  {
  print('error $error');
  }
    
  }
   
}