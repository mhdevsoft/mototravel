import 'package:geoflutterfire/geoflutterfire.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';


class GeoFireProvider
{
  //Objetos
 CollectionReference _ref;
 Geoflutterfire _geo;
 GeoFireProvider()
 {
   //inicializar variables
   _ref = FirebaseFirestore.instance.collection('locations');
   _geo = Geoflutterfire();
 }
Stream<List<DocumentSnapshot>> getNearbyDrivers(double lat, double lng, double radius)
{
  //punto donde nos encontramos 
 GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);
 //obtener todos los mototaxis a mi alrededor
 return _geo.collection(collectionRef: _ref.where('status',isEqualTo: 'drivers_available')).within(center: center, radius: radius, field: 'position');
}
  //metodo
 //obtener de la base de datos en tiempo real
Stream<DocumentSnapshot> getLocationByIdStream(String id)
{
  return _ref.doc(id).snapshots(includeMetadataChanges: true);

}


 Future <void> create (String id, double lat, double lng)
 {
   GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
   return _ref.doc(id).set({'status': 'drivers_available', 'position': myLocation.data});
   }

    Future <void> createSet (String id, double lat, double lng)
 {
   GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
   return _ref.doc(id).set({'status': 'drivers_working', 'position': myLocation.data});
   }

  Future<void> delete (String id)
  {
     return _ref.doc(id).delete();
  }
}