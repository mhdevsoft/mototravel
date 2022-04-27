import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mototravel/src/models/cliente.dart';
import 'package:mototravel/src/pages/providers/client_providers.dart';
import 'package:mototravel/src/pages/providers/driver_providers.dart';
import 'package:http/http.dart' as http;
import 'package:mototravel/src/utils/shared_pref.dart';

class PushNotificationsProvider
{
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  //Informacion que enviara para las notificaciones
  StreamController _streamController = StreamController<Map<String ,dynamic>>.broadcast();

  Stream<Map<String ,dynamic>> get message => _streamController.stream;


  void initPushNotificacions () async
  {
    //On Launch
     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
         Map<String ,dynamic> data = message.data;
         SharedPref sharedPref = SharedPref();
         sharedPref.save('isNotification', 'true');
         _streamController.sink.add(data);
      }
    });
    //ON Message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      Map<String ,dynamic> data = message.data;
      print('Primer Plano');
      print('On Message $data');
      _streamController.sink.add(data);
      }
    );
     //On Resume
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String ,dynamic> data = message.data;
      print('On Resume $data');
      _streamController.sink.add(data);
    });

   
  }
  //Guardar Tokens Unicos
  void saveToken(String idUser , String typeUser)async
  {
     //Generamos el token unico solo para dispositivos especificos
    String token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = {
    'token': token
    };

    if (typeUser == 'client') {
      ClientProvider clientProvider = new ClientProvider();
      clientProvider.update(data, idUser);
    }
    else
    {
      DriverProvider driverProvider = new DriverProvider();
      driverProvider.update(data, idUser);
    }
  }

  //Envio para notificiaciones push via HTTP
  Future<void> sendMessage (String to, Map<String, dynamic> data, String title, String body ) async
  {
    await http.post(
       'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAoSoFwlw:APA91bHSDpl11Sfl_kU6GTMc9RS8gCOVxjbCbIoj9Jo8zIILE6_MLMAaKblY0wE-DDyvTVeS4yP1C-qfkhcJxtKmF_Ay0lRAlGxE4SymqC_0Zka4O7seqe7AA99PKkslejHQ1rp5Yi4V'
      },
      body: jsonEncode(
        <String, dynamic>  {
          'notification':<String ,dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to
        }
      )

      );

  }


  void dispose ()
  {
    _streamController?.onCancel;
  }


}