import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/driver.dart';

class DriverProvider

{
  CollectionReference _ref;

  DriverProvider ()
  {
    _ref = FirebaseFirestore.instance.collection('Conductor');
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
}