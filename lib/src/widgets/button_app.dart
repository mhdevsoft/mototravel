import 'package:flutter/material.dart';

class buttonApp  extends StatelessWidget {
   Color color;
   String text;
   Color textApp;
   IconData icon;
   Function onPresed;
   //Construcctor para los colores
   buttonApp({
    this.color = Colors.blue,
    this.textApp,
    this.icon = Icons.arrow_forward_ios,
    this.onPresed,
   @required this.text
   });
  @override
  Widget build(BuildContext context) {
    return RaisedButton(onPressed: (){

      onPresed();
    },
    color: color,
    //establece elementos uno encima del otro
    child: Stack(children: [
        Align(
         alignment: Alignment.center,
         child: Container(
           alignment: Alignment.center,
           height: 40,
           child: Text (text, 
           style: TextStyle(fontSize: 16,
           fontWeight:FontWeight.bold),
           )),


        ),
       Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 40,
            child: CircleAvatar(radius: 15,  child: Icon(icon,  color: Colors.black),
            backgroundColor: Colors.white,
         ),
          ),
        )
    ],
    ),
    textColor: textApp,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}