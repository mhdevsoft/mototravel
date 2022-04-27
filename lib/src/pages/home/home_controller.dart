import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mototravel/src/pages/providers/auth_providers.dart';
import 'package:mototravel/src/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homecontroller
{
  //NULL SAFETY
  // ? si usamos la version 2.12
  BuildContext context;
  SharedPref _sharedPref;
  AuthProvider _authProvider;
  String _typeUser; 
  String  _isNotification;  
 //recibimos los parametros de buildcontext
  Future init(BuildContext context)async
  {
     this.context = context;
     _sharedPref = new SharedPref();
     _authProvider = new AuthProvider();
     _typeUser = await _sharedPref.read('typeUser');
     _isNotification = await _sharedPref.read('isNotification');
     checkIfUser();
  }
  //verifica si el ususario esta logueado y si esta lo lleva directo a la aplicacion
  void checkIfUser(){
  bool isSigned = _authProvider.IsSignedIn();

  if (isSigned ) {

    if (_isNotification != 'true') {
         if (_typeUser == 'client') {
      Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
    }
    else
    {
      Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
    }
     }
     
  }
  }
    //creamos un metodo void el cual no retornara nada pero realizara una accion
    //guardara la informacion del tipo de usuario
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