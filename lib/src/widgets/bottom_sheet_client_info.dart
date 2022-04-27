import 'package:flutter/material.dart';

class BottomSheetClientInfo extends StatefulWidget {

  String imageUrl;
  String username;
  String email;
  String placa;

  BottomSheetClientInfo ({
   @required this.imageUrl,
   @required this.username,
   @required this.email,
   @required this.placa,
  });

  @override
  _BottomSheetClientInfoState createState() => _BottomSheetClientInfoState();
}

class _BottomSheetClientInfoState extends State<BottomSheetClientInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Text('¿Quien Conduce?',
          style: TextStyle(fontSize: 18),
          ),
         SizedBox(height: 15),
        CircleAvatar(
          backgroundImage: AssetImage('assets/img/found.png'),
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
           title: Text('Telefono Movil',
           style: TextStyle(fontSize: 15)
           ),
           subtitle: Text(widget.email ?? '',
           style: TextStyle(fontSize: 15)
         ),
         leading: Icon(Icons.call),
         ),
          ListTile(
           title: Text('Placa Mototaxi',
           style: TextStyle(fontSize: 15)
           ),
           subtitle: Text(widget.placa  ?? '',
           style: TextStyle(fontSize: 15)
         ),
         leading: Icon(Icons.directions_bike_rounded),
         ),
        ],
      ),
    );
  }
}