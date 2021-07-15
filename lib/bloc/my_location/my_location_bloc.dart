import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:meta/meta.dart';

part 'my_location_event.dart';
part 'my_location_state.dart';

class MyLocationBloc extends Bloc<MyLocationEvent, MyLocationState> {

  //Constructor
  MyLocationBloc() : super( MyLocationState() );

  //Posición del usuario
  late StreamSubscription<Position> _positionSubscription;


  //Método para iniciar el seguimiento de la localización del usuario, realizamos la llamada cuando entramos en el mapPage
  void startMonitoring() {

    /*final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );*/

    _positionSubscription = Geolocator.getPositionStream( 
      //Precisión de la localización
      desiredAccuracy: LocationAccuracy.high,
      //Emite cada vez que cambia 10 metros la ubicación
      distanceFilter: 10
      ).listen(( Position position ) {
        //Obtengo la última ubicación conocida del usuario
        final newLocation = new LatLng( position.latitude, position.longitude );
        //Disparo el evento que muestra la última ubicación cnocida con el state actualizado
        add( OnLocationChange( newLocation ) );
    });

  }

  //Método para finalizar el seguimiento, destruimos el Widget y no lo implementamos
  void cancelMonitoring() {
    _positionSubscription.cancel();
  }

  @override
  Stream<MyLocationState> mapEventToState( MyLocationEvent event ) async* {
    
    //Verificamos que si el evento que se dispara es OnLocationChange
    if ( event is OnLocationChange ) {
      //Emito un nuevo state, haciendo copia del estado actual mediante copyWith()
      yield state.copyWith(
        //Envio la nueva ubicación
        existsLocation: true,
        location: event.location
      );
    }
  }
}
