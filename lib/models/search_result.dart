import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

//Clase para controlar la información que devuelve el SearchDelegate
class SearchResult {

  //Nos permite concoer si el usuario cancela el SearchDelegate
  final bool unsubscribe;
  //Nos permite cnocner si el usuario solicta establecer una localización de forma manual
  final bool? manualLocation;
  //Coordenadas cuando el usuario realiza la búsqueda
  final LatLng? position;
  //Nombre del destino
  final String? destinationName;
  final String? description;

  SearchResult({
    required this.unsubscribe,
    this.manualLocation,
    this.position,
    this.destinationName,
    this.description
  });


}