import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:mototravel/src/pages/driver/travel_calification/driver_travel_calification_controller.dart';
import 'package:mototravel/src/widgets/button_app.dart';
class DriverTravelCalificationPage extends StatefulWidget {

  @override
  _DriverTravelCalificationPageState createState() => _DriverTravelCalificationPageState();
}

class _DriverTravelCalificationPageState extends State<DriverTravelCalificationPage> {
  DriverTravelCalificationController _con  = new DriverTravelCalificationController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      bottomNavigationBar: _buttonCalificate(),
      body: Column(
      children: [
      _bannerPriceInfo(),
      _listTileTravelInfo('Desde', _con.travelHistory?.from ?? '', Icons.location_on), 
      _listTileTravelInfo('Hasta', _con.travelHistory?.to ?? '', Icons.directions_subway), 
      SizedBox(height: 30),
      _textCalificacionDriver(),
      SizedBox(height: 15,),
      _ratingbar()
      ],
      ),
    );
  }

Widget _buttonCalificate()
{
  return Container(
    height: 50,
    margin: EdgeInsets.all(30),
    child: buttonApp(
      onPresed: _con.calificate,
      text: 'FINALIZAR',
      textApp: Colors.white,
       color: Colors.green,),
  );
}

 Widget _ratingbar()
 {
   return Center(
     child: RatingBar.builder
     (itemBuilder: (context, _) => Icon(Icons.star,color: Colors.amber),
     unratedColor: Colors.grey[300], 
     itemCount: 5,
     initialRating: 0,
     direction: Axis.horizontal,
     allowHalfRating: true,
     itemPadding: EdgeInsets.symmetric(horizontal: 4), 
     onRatingUpdate: (rating)
     {
       _con.calification= rating;
       print('RATING: $rating');
     }),
   );
 }

  Widget _textCalificacionDriver()
  {
    return Text('CALIFICA A TU CLIENTE',
    style: TextStyle(
    color: Colors.cyan,
    fontWeight: FontWeight.bold,
    fontSize: 16
    ),
    );
  }

  Widget _bannerPriceInfo()
  {
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        height: 300,
        width: double.infinity,
        color: Colors.green,
        child: SafeArea(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.grey[800], size: 100),
              SizedBox(height: 20),
              Text('¡El Viaje Ha Finalizado!', style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              ),
              SizedBox(height: 30),
                 Text('Costo Total', style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              ),
              SizedBox(height: 5),
                 Text('15\$', style: TextStyle(
                fontSize: 25,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              ),
              ],
          ),
        ),
      ),
    );
  }


  Widget _listTileTravelInfo(String title, String value, IconData icon)
  {
   return Container(
     width: double.infinity,
     alignment: Alignment.center,
     margin: EdgeInsets.symmetric(horizontal: 30),
     child: ListTile(
     title: Text(title,
     style: TextStyle(
       color: Colors.black,
       fontWeight: FontWeight.bold,
       fontSize: 14
     ),
     maxLines: 1),

  subtitle: Text(value,
     style: TextStyle(
       color: Colors.grey,
       fontWeight: FontWeight.bold,
       fontSize: 14
     ),
      maxLines: 2
      ,),
  leading: Icon(icon, color:Colors.grey)

  ),
   );
  }
  void refresh() {
  setState(() {
    
  });
  }
}