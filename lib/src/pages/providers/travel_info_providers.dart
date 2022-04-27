import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/travel_info.dart';

class TravelInfoProvider
{
 CollectionReference _ref;

 TravelInfoProvider()
 {
   _ref = FirebaseFirestore.instance.collection('TravelInfo');
 }
 //Escucharemos los cambios de la base de datos para el viaje

Stream<DocumentSnapshot> getByIdStream(String id)
{
 return _ref.doc(id).snapshots(includeMetadataChanges: true);
}

//obtenemos la informacion del viaje 1 sola vez de la base de datos
  Future<TravelInfo> getById(String id)async
  {
    //es el documento de la base de datos del cliente que va a leer
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());
      return travelInfo;
    }

   else
   {
     return null;
   }
  }

 //Metodo para crear Informacion 
Future<void> create(TravelInfo travelInfo)
  {
    String errorMessage;

    try
    {
      return _ref.doc(travelInfo.id).set(travelInfo.toJson());
    }
    catch(error)
    {
      errorMessage = error;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }


  }
  //Actualizar datos hacia la base de datos

   Future<void> update (Map<String, dynamic> data, String id)
  {
    return _ref.doc(id).update(data);
  }

}