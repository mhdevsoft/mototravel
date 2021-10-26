import 'package:flutter/material.dart';

class homecontroller
{
  //NULL SAFETY
  // ? si usamos la version 2.12
  BuildContext context;

 //recibimos los parametros de buildcontext
  Future init(BuildContext context)
  {
     this.context = context;
  }
    //creamos un metodo void el cual no retornara nada pero realizara una accion
   void goToLogin() 
   {
     Navigator.pushNamed(context, 'login');
   }
}