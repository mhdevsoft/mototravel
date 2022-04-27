import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/costos.dart';

class CostosProviders {

  CollectionReference _ref;

  CostosProviders ()
  {
    _ref = FirebaseFirestore.instance.collection('Prices');
  }

    Future<Costos> getAll() async{
    DocumentSnapshot document = await _ref.doc('Info').get();
    Costos costos = Costos.fromJson(document.data());
    return costos;
  }
}