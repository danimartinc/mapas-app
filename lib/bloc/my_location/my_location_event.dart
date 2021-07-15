part of 'my_location_bloc.dart';

@immutable
abstract class MyLocationEvent {}

//Evento que modfique el state del Bloc, después de obtener la última ubicación conocida del usuario, para enviarlo al mapEventToState
class OnLocationChange extends MyLocationEvent {
  //Nuevas coordenadas conocidas
  final LatLng location;

  //Constructor
  OnLocationChange(this.location);
}

//Listener qué escuche los cambios de ubicación que se producen en el GPS, según se modifica voy cambiando mi state