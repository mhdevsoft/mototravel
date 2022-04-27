import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/driver.dart';

class DriverProvider

{
  CollectionReference _ref;

  DriverProvider ()
  {
    _ref = FirebaseFirestore.instance.collection('drivers');
  }

  Future<void> create(Drive driver)
  {
    String errorMessage;

    try
    {
      return _ref.doc(driver.id).set(driver.toJson());
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

   Future<Drive> getById(String id)async
  {
    //es el documento de la base de datos del cliente que va a leer pero sola una vez
    DocumentSnapshot document = await _ref.doc(id).get();
    if (document.exists) {
      Drive drive = Drive.fromJson(document.data());
      return drive;
    }
  return null;

  }

  Future<void> update (Map<String, dynamic> data, String id)
  {
    return _ref.doc(id).update(data);
  }
}