import 'package:flutter/material.dart';
import 'package:mototravel/src/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homecontroller
{
  //NULL SAFETY
  // ? si usamos la version 2.12
  BuildContext context;
  SharedPref _sharedPref;
 //recibimos los parametros de buildcontext
  Future init(BuildContext context)
  {
     this.context = context;
     _sharedPref = new SharedPref();  
  }
    //creamos un metodo void el cual no retornara nada pero realizara una accion
   void goToLogin(String typeUser) 
   {
     saveTypeUser(typeUser);
   }

   void saveTypeUser(String typeUser)async
   {
     await _sharedPref.save('typeUser', typeUser);
     Navigator.pushNamed(context, 'login');
   }
}