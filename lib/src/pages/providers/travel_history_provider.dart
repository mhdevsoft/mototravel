import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/TravelHistory.dart';

class TravelHistoryProvider

{
  CollectionReference _ref;

  TravelHistoryProvider ()
  {
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String> create(TravelHistory travelHistory) async
  {
    String errorMessage;

    try
    {
      String id = _ref.doc().id;
      travelHistory.id = id;
      
      await _ref.doc().set(travelHistory.toJson()); // ALMACENAMOS LA INFORMACION
      return id;
    } catch(error) {
      errorMessage = error.code;
    }
    catch(error)
    {
      errorMessage = error;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }


  }
   Stream<DocumentSnapshot> getByIdStream(String id)
  {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  //Consulta a la base de datos del cliente
 //Rernorara un objeto tipo cliente por su ID
  Future<TravelHistory> getById(String id)async
  {
    //es el documento de la base de datos del cliente que va a leer
    DocumentSnapshot document = await _ref.doc(id).get();
    if (document.exists) {
      TravelHistory travelHistory = TravelHistory.fromJson(document.data());
      return travelHistory;
    }
   else
   {
     return null;
   }
  }

  Future<void> update (Map<String, dynamic> data, String id)
  {
    return _ref.doc(id).update(data);
  }

  Future<void> delete (String id) {
    return _ref.doc(id).delete();
  }
}