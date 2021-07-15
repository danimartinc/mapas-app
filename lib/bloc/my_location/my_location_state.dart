part of 'my_location_bloc.dart';


@immutable
class MyLocationState {

  //Propiedades en final ya que no deben cambiar
  //Propiedad que permite que el usuario quiere que rastreemos su localización o lo quiere desactivar
  final bool? following;
  //Permite conocer si tengo o no la última ubicación conocida del usuario.Si tengo ubicación en true, si no false
  final bool existsLocation;
  //Ubicación del usuario definida en latitud y longitud
  final LatLng? location;

  //Constructor
  MyLocationState({
    this.following = true,
    this.existsLocation = false,
    this.location
  }); 

  //copyWith(), método que realiza una copia del MyLocationState en el estado actual, que devuelve una instancia de MyLocationState
  MyLocationState copyWith({
    //Paso todas las propiedades de la clase como argumento
    bool? following,
    required bool existsLocation,
    LatLng? location,
  }) => new MyLocationState(
    following      : following,
    existsLocation : existsLocation,
    location       : location,
  );

}
