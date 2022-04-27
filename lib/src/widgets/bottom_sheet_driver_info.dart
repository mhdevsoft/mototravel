import 'package:flutter/material.dart';

class BottomSheetDriverInfo extends StatefulWidget {

  String imageUrl;
  String username;
  String email;
  String telefono;

  BottomSheetDriverInfo ({
   @required this.imageUrl,
   @required this.username,
   @required this.email,
   @required this.telefono,
  });

  @override
  _BottomSheetDriverInfoState createState() => _BottomSheetDriverInfoState();
}

class _BottomSheetDriverInfoState extends State<BottomSheetDriverInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Informacion del Cliente',
          style: TextStyle(fontSize: 18),
          ),
         SizedBox(height: 15),
        CircleAvatar(
          backgroundImage: AssetImage('assets/img/user.png'),
          radius: 50,
        ),
         ListTile(
           title: Text('Nombre',
           style: TextStyle(fontSize: 15)
           ),
           subtitle: Text(widget.username ?? '',
           style: TextStyle(fontSize: 15)
         ),
         leading: Icon(Icons.person),
         ),
               ListTile(
           title: Text('Correo',
           style: TextStyle(fontSize: 15)
           ),
           subtitle: Text(widget.email ?? '',
           style: TextStyle(fontSize: 15)
         ),
         leading: Icon(Icons.email),
         ),
          ListTile(
           title: Text('Telefono de Contacto',
           style: TextStyle(fontSize: 15)
           ),
           subtitle: Text(widget.telefono  ?? '',
           style: TextStyle(fontSize: 15)
         ),
         leading: Icon(Icons.call)
         ),
        ],
      ),
    );
  }
}