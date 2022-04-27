import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mototravel/src/models/cliente.dart';

class ClientProvider

{
  CollectionReference _ref;

  ClientProvider ()
  {
    _ref = FirebaseFirestore.instance.collection('clients');
  }

  Future<void> create(Client client)
  {
    String errorMessage;

    try
    {
      return _ref.doc(client.id).set(client.toJson());
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
  Future<Client> getById(String id)async
  {
    //es el documento de la base de datos del cliente que va a leer
    DocumentSnapshot document = await _ref.doc(id).get();
    if (document.exists) {
      Client client = Client.fromJson(document.data());
      return client;
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
}