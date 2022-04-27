import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider 
{
  //instanciar una varable de tipo firebase

  FirebaseAuth _firebaseAuth;


  AuthProvider()
  {
    _firebaseAuth = FirebaseAuth.instance;
  }  

  User getUser()
  {
    //inicamos sesion los datos comparamos
    return _firebaseAuth.currentUser;
  }
  //verificar si esta logeado el usuario para evitar multiples logueos y exista un loop
  bool IsSignedIn(){

    final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null ) {
        return false;
      } 

      return true;
  }
  void  checkUserLogin (BuildContext context, String typeUser)
  {
    FirebaseAuth.instance.authStateChanges().listen((User user) { 
      //el usuario esta logeado
     if (user != null && typeUser != null) {
       if (typeUser == 'client' ) {
         Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
       }
        else{
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
        }
     }
     else
     {
      return;
     }

    });
  }
 //async hara un peteicion a la nube y no se sabra en que momento lo recibira
  Future<bool>  login(String email, String password) async
  {
    String errorMessage;

    try
    {
      //await esperara hasta que el proceso se termine
     await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } 
    catch(error)
    {
      print(error);
        //login incorrecto o sin internet
      errorMessage = error.code;
    }
    //en caso que entro en catch retornaremos un mensaje
    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
    return true;
  }

  Future<bool>register(String email, String password) async
  {
    String errorMessage;

    try
    {
      //await esperara hasta que el proceso se termine
     await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } 
    catch(error)
    {
      print(error);
        //login incorrecto o sin internet
      errorMessage = error.code;
    }
    //en caso que entro en catch retornaremos un mensaje
    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
    return true;
  }
   //Cierra Sesion 
   Future<void> signOut()async
   {
      return Future.wait([_firebaseAuth.signOut()]);
   }


}

