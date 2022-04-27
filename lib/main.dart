import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mototravel/src/pages/client/map/client_map_page.dart';
import 'package:mototravel/src/pages/client/travel_calification/client_travel_calification_page.dart';
import 'package:mototravel/src/pages/client/travel_map/client_travel_map_page.dart';
import 'package:mototravel/src/pages/client/travel_request/client_request_page.dart';
import 'package:mototravel/src/pages/client/viaje_info/travel_info_page.dart';
import 'package:mototravel/src/pages/driver/map/driver_map_page.dart';
import 'package:mototravel/src/pages/driver/register/driver_register_page.dart';
import 'package:mototravel/src/pages/driver/travel_calification/driver_travel_calification_page.dart';
import 'package:mototravel/src/pages/driver/travel_map/drive_travel_map_page.dart';
import 'package:mototravel/src/pages/driver/viaje_request/driver_request_viaje_page.dart';
import 'package:mototravel/src/pages/home/home_page.dart';
import 'package:mototravel/src/pages/login/login_page.dart';
import 'package:mototravel/src/pages/client/register/client_register_page.dart';
import 'package:mototravel/src/pages/providers/push_notificaciones_provider.dart';
import 'package:mototravel/src/utils/colors.dart' as tema;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
void main() async{
  //Inicializamos Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
//Clase hereda nuestras pantalla para que pueda dar intercacion
//Los que mas ocuparemos
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     //Inicializamos las notificaciones
    PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
    pushNotificationsProvider.initPushNotificacions();

    pushNotificationsProvider.message.listen((data) {
      print('notificacion envio');
      print(data);

     navigatorKey.currentState.pushNamed('driver/travel/request', arguments: data);
     });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moto Travel',//propiedad
      navigatorKey: navigatorKey, //llave global
      initialRoute: 'home',//la ruta que se va ejecutar por primera vez la app
       theme: ThemeData(
        fontFamily: 'Fuente', //Para desaparecer por completo el toolbar o linea
         appBarTheme: AppBarTheme(
         elevation: 0
       ),
        primaryColor: Colors.black
      ),//Aplicamosun Fuente Primaria
      routes: {
         'home': (BuildContext context)=> HomePage(),
         'login': (BuildContext context)=> LoginPage(), //Objeto y llamamos la clase BulidContext
         'client/register': (BuildContext context)=> ClientRegisterPage(), 
         'driver/register': (BuildContext context)=> DriverRegisterPage(),
         'driver/map': (BuildContext context)=> DriverMapPage(),
         'driver/travel/request': (BuildContext context)=> DriverlTravelRequestPage(),
         'driver/travel/map': (BuildContext context)=>DriverTravelMapPage(),
         'driver/travel/calification': (BuildContext context)=>DriverTravelCalificationPage(),
         'client/map': (BuildContext context)=> ClientMapPage(),
         'client/viaje/info': (BuildContext context)=> ClientTravelInfoPage(),
         'client/viaje/request': (BuildContext context)=> ClientTravelRequestPage(),
         'client/viaje/map': (BuildContext context)=> ClientTravelMapPage(),
         'client/travel/calification': (BuildContext context)=>ClientTravelCalificationPage(),

      },
    );//Respetar Parentesis y Corchetes 
  }
}