
import 'package:flutter/material.dart';

class Snackbar
{
  static void showSnackbar(BuildContext context, GlobalKey<ScaffoldState> key, String text)
  {
    if (context == null) return;
    if (key == null) return;
    if (key.currentState == null) return;

    FocusScope.of(context).requestFocus(new FocusNode());
    //en caso que venga vacio no lo muestra xd
    key.currentState?.removeCurrentSnackBar();
    key.currentState.showSnackBar(new SnackBar(
     content: Text(
       text,
       textAlign: TextAlign.center,
       style: TextStyle
       (
         color: Colors.white,
        fontSize: 14 
       ),
     ),
     backgroundColor: Colors.black,
     duration: Duration(seconds: 3)
    ));
  }
}