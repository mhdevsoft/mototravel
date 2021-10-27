import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider 
{
  //instanciar una varable de tipo firebase

  FirebaseAuth _firebaseAuth;


  AuthProvider()
  {
    _firebaseAuth = FirebaseAuth.instance;
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
}