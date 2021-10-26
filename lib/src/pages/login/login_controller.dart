import 'package:flutter/material.dart';

class loginController
{

// inicializamos el context el cual esto es nuestro construcctor
  BuildContext context;
  // con esto permitimos y obtener los datos que escriba el cliente
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  Future init  (BuildContext context)
  {
    this.context = context;
  }

  void login ()
  {
      String email = emailController.text;
      String pass =  passController.text;

      print('Email: $email');
      print('pass: $pass');
  }
   
}