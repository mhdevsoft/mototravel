import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class SharedPref
{

  //Metodo para guardar datos persistente del cliente
 void save (String key ,String value) async
{
  final prefs = await SharedPreferences.getInstance();
  //necesitamos json para mostrar el valor
  prefs.setString(key, jsonEncode(value));
}
//metodo para leer datos persistentes del cliente

Future <dynamic> read  (String key)
async
{
  final prefs = await SharedPreferences.getInstance();
  return json.decode(prefs.getString(key));
}
//Ejemplo Nombre - true - false
//Si existe un valor con una llave establecid
  Future<bool> contains(String key)async
 {
   final prefs = await SharedPreferences.getInstance();
   return prefs.containsKey(key);
 }

 Future<bool> remove (String key)async
 {
   final prefs = await SharedPreferences.getInstance();
   return prefs.remove(key);
 }
}