import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
//Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart';
//Estilo mapa Uber
import 'package:mapas_app/themes/uber_map.dart';


part 'map_event.dart';
part 'map_state.dart';

//Se encarga a realizar todas las implementaciones relacionadas con el mapa
class MapBloc extends Bloc<MapEvent, MapState> {

  //Constructor
  MapBloc() : super( new MapState() );

  //Controlador del mapa
  GoogleMapController? _mapController;

  //Estructura de las polylines por defecto
  Polyline _myRoute = new Polyline(
    //ID único asignado a cada Polyline
    polylineId: PolylineId('my_route'),
    width: 4,
    color: Colors.transparent,
  );

  //Estructura de las polylines por defecto
  Polyline _myDestinationRoute = new Polyline(
    //ID único asignado a cada Polyline
    polylineId: PolylineId('my_destination_route'),
    width: 4,
    color: Colors.black87,
  );

  //Método para inicializar el GoogleMap mediante el onMapCreated
  void initMapa( GoogleMapController controller ) {
    //Comprobamos que si el mapa está disponible, para evitar su llamada recurrente
    if ( !state.availableMap! ) {
      //Si no está diponible el mapa, puedo obtener la referencia del controller
      this._mapController = controller;
      //setMapStyle(), permite cambiar el estilo del mapa
      this._mapController!.setMapStyle( jsonEncode( uberMapTheme ) );
      //Disparamos el evento para modificar el state del mapa
      add( OnAvailableMap() );
    }
    
  }
    //Método que permite mover la cámara al seleccionar el botón
    //Ubicación del destino, latitud y longitud
    void moveCamera( LatLng destination ) {
      //Nos permite cambiar la camra de posición
      final cameraUpdate = CameraUpdate.newLatLng( destination );
      //Disparo el controller y lo mue
      this._mapController!.animateCamera( cameraUpdate );
    }

  @override
  Stream<MapState> mapEventToState( MapEvent event, ) async* {
    
    //Compruebo que si el evento que recibo es de tipo OnAvailableMap
    if ( event is OnAvailableMap ) {
      //Mediante yield, emito un nuevo estado, 
      //copyWith(), permite realizar una copia del estado actual y emitir el nuevo estado con la propiedad modificada
      //Indicamos que el mapa está disponible
      yield state.copyWith( availableMap: true );
      //Compruebo que si el evento que recibo es de tipo OnNewLocation
      } else if ( event is OnNewLocation ) {
        //Mediante el *, indicamos que no devuelva el Stream, si no que devuelva la emisión del Stream
        yield* this._onNewLocation( event );

      } else if ( event is OnMarkRoute ) {
        yield* this._onMarkRoute( event );
      
      } else if ( event is OnFollowLocation ) {
        //Emitimos el nuevo estado
        yield* this._onSeguirUbicacion( event );
      } else if ( event is OnUserMovedMap ) {
        //Establecemos la ubicación central como la ubicación que recibimos mediante el evento
        yield state.copyWith( centralLocation: event.mapCenter );
      //Compruebo que si el evento es de tipo OncreateStartAndDestinationRoute
      } else if ( event is OncreateStartAndDestinationRoute ) {
        //Emito el nuevo state
        yield* this._onCreateStartAndDestinationRoute( event );
    }
  }

  //Método generador, async*, que dispara el evento de tipo _onNuevaUbicacion, devuelve un Stream
  Stream<MapState> _onNewLocation( OnNewLocation event ) async* {

    //Compruebo si el followLocation está activado
    if ( state.followLocation! ) {
      //Si está activado hay que mover la cámara al punto de coordenadas respectivo
      this.moveCamera( event.location );
    }

    //Creamos una copia, para mantener el state anterior
    //Lista que contiene los puntos del Polyline
    //Mediante ... se extraen todos todos los puntos de cooordenadas de la ruta y añado al state la nueva localización
    final points = [ ...this._myRoute.points, event.location ];
    //Creo una copia del state actual y envio los nuevos puntos de coordenadas obtenidos
    this._myRoute = this._myRoute.copyWith( pointsParam: points );

    //Mantengo la referencia a los polylines del state anterior
    final currentPolylines = state.polylines;
    //Asigno como key el my_route, y apunta a la ruta
    currentPolylines!['my_route'] = this._myRoute;
    //Emito un nuevo estado, realizando una copia de las currentPolylines del state actual
    yield state.copyWith( polylines: currentPolylines );

  }

  //Método generador, async*, que dispara el evento de tipo _onMarkRoute, devuelve un Stream
  Stream<MapState> _onMarkRoute( OnMarkRoute event ) async* {

    //Comprobamos el valor del boolean drawRoute en el state actual
    if ( !state.drawRoute! ) {
      //En este caso si es true, tengo que mantener el color de la linea en el que está
      //Realizo una copia de la ruta actual, solo cambio el color de la ruta
      this._myRoute = this._myRoute.copyWith( colorParam: Colors.black87 );
    } else {
      //En caso de que sea false, ocultamso la ruta estableciendo el color como transparente
      this._myRoute = this._myRoute.copyWith( colorParam: Colors.transparent );
    }

    //Mantengo la referencia a los polylines del state anterior
    final currentPolylines = state.polylines;
    //Asigno como key el my_route, y apunta a la nueva ruta cambiando el color de la linea
    currentPolylines!['my_route'] = this._myRoute;
    //Emito un nuevo estado, realizando una copia de las currentPolylines del state actual
    yield state.copyWith(
      //drawRoute opuesto al valor actual
      drawRoute: !state.drawRoute!,
      polylines: currentPolylines
    );

  }

  Stream<MapState> _onSeguirUbicacion( OnFollowLocation event ) async* {

    //Compruebo que si followLocation está en false, lo activamos. El usuario acaba de seleccionar el botón para iniciar el seguimiento
    if ( !state.followLocation! ) {
      //Movemos la cámara hacia el destino. Obtengo los puntos desde el polyline de la ruta mediante el array de LatLng
      this.moveCamera( this._myRoute.points[ this._myRoute.points.length - 1 ] );
    }
    //Emitimos el nuevo estado, realizando una copia del actual, el followLocation va a ser el opuesto al que se encuentra en el state actual
    yield state.copyWith( followLocation: !state.followLocation! );
  }

  //Método generador, async*, que dispara el evento de tipo OncreateStartAndDestinationRoute, devuelve un Stream de tipo MapState
  Stream<MapState> _onCreateStartAndDestinationRoute( OncreateStartAndDestinationRoute event ) async* {

    //Configuramos la polyline de la ruta destino, asignando las nuevas rutas
    //Realizamos la copia del state actual de la ruta, y copiamos los pointsParams para obtener el lsitado de pares de coordenadas
    this._myDestinationRoute = this._myDestinationRoute.copyWith(
      pointsParam: event.routeCoordinates
    );

    //Extraemos las currentPolylines del state anterior y las almaceno
    final currentPolylines = state.polylines;
    //Añado una nueva polyline al Map(), indicando el ID de la DestinationRoute
    currentPolylines!['my_destination_route'] = this._myDestinationRoute;

    // Icono inicio
    // final iconInicio  = await getAssetImageMarker();
   // final iconInicio  = await getMarkerInicioIcon( event.duracion.toInt() );

  //  final iconDestino = await getMarkerDestinoIcon(event.nombreDestino, event.distancia);
    // final iconDestino = await getNetworkImageMarker();

    // Marcadores
  /*  final markerInicio = new Marker(
      anchor: Offset(0.0, 1.0),
      markerId: MarkerId('inicio'),
      position: event.rutaCoordenadas[0],
      icon: iconInicio,
      infoWindow: InfoWindow(
        title: 'Mi Ubicación',
        snippet: 'Duración recorrido: ${ (event.duracion / 60).floor() } minutos',
      )
    );

    double kilometros = event.distancia / 1000;
    kilometros = (kilometros * 100).floor().toDouble();
    kilometros = kilometros / 100;

    final markerDestino = new Marker(
      markerId: MarkerId('destino'),
      position: event.rutaCoordenadas[ event.rutaCoordenadas.length - 1 ],
      icon: iconDestino,
      anchor: Offset(0.1, 0.90),
      infoWindow: InfoWindow(
        title: event.nombreDestino,
        snippet: 'Distancia: $kilometros Km',
      )
    );

    final newMarkers = { ...state.markers };
    newMarkers['inicio']  = markerInicio;
    newMarkers['destino'] = markerDestino;

    Future.delayed(Duration(milliseconds: 300)).then(
      (value) {
        // _mapController.showMarkerInfoWindow(MarkerId('inicio'));
        // _mapController.showMarkerInfoWindow(MarkerId('destino'));
      }
    );*/

    //Devuelvo un nuevo estado
    yield state.copyWith(
      //Añado las nuevas polylines al nuevo state
      polylines: currentPolylines,
      //markers: newMarkers
    );
  }

}