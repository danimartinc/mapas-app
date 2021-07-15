part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

//Evento que modifica el state e indica que el mapa está disponible. Mapa cargado, controlador disponible, referencia...
class OnAvailableMap extends MapEvent{}

//Evento que se dispara cada vez que cambia la ubicación del usuario
class OnNewLocation extends MapEvent{
  final LatLng location;
  OnNewLocation(this.location);
}

//Evento para modificar el valor del boolean de drawRoute, un toogle
class OnMarkRoute extends MapEvent{}

//Evento que permite activar/desactivar el seguimiento del usuario en su recorrido por el mapa
class OnFollowLocation extends MapEvent{}

//Evento que reciba la información de la ruta para crear 
class OncreateStartAndDestinationRoute extends MapEvent{

  //Ruta de las coordenadas
  final List<LatLng>? routeCoordinates;
  final double? distance;
  final double? duration;
 // final String? nameDestination;

  OncreateStartAndDestinationRoute( this.routeCoordinates, this.distance, this.duration, /*this.nameDestination*/ );

}

//Evento que permite obtener el centro del mapa en el que se meuve el usuario
class OnUserMovedMap extends MapEvent{

  final LatLng mapCenter;
  //Constructor
  OnUserMovedMap(this.mapCenter);
  
}

