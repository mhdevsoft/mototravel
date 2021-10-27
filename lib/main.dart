import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mototravel/src/pages/home/home_page.dart';
import 'package:mototravel/src/pages/login/login_page.dart';
import 'package:mototravel/src/utils/colors.dart' as tema;
void main() async{
  //Inicializamos Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
//Clase hereda nuestras pantalla para que pueda dar intercacion
//Los que mas ocuparemos
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moto Travel',//propiedad
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
      },
    );//Respetar Parentesis y Corchetes
  }
}