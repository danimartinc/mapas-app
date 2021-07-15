part of 'map_bloc.dart';

@immutable
class MapState {

  //Indica cuando el mapa está disponible para ser implementado
  final bool? availableMap;
  //Nos permite activar/desactivar el polyline de la ruta del recorrido
  final bool? drawRoute;
  //Permite activas/dessactivar el seguimiento del usuario por el mapa
  final bool? followLocation;
  //Nos permite conocer las coordenadas del punto central del mapa, indiferente de la ubicación en la que estemos, cada vez que se mueve el mapa se calcula la ubicación
  final LatLng? centralLocation;

  //Polylines, Map() cuya key es un String y el tipo de valor es Polyline
  //Polyline, linea junto con los puntos de coordenadas que la forman, grosor y color
  final Map<String, Polyline>? polylines;
  final Map<String, Marker>? markers;

  //Constructor
  MapState({
    this.availableMap   = false,
    this.drawRoute      = false,
    //Por defecto, no se realiza el seguimiento
    this.followLocation = false,
    this.centralLocation,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers
      //Inicializo las polylines, si no se reciben, creamos un nuevo mapa
  }) : this.polylines = polylines ?? new Map(),
       this.markers = markers ?? new Map();


  MapState copyWith({
    bool? availableMap,
    bool? drawRoute,
    bool? followLocation,
    LatLng? centralLocation,
    Map<String, Polyline>? polylines,
   // Map<String, Marker> markers
  }) => MapState(
    //Comprobamos que si viene la propiedad como argumento la insertamos, si no establecemos el valor del state actual
    availableMap: availableMap ?? this.availableMap,
    polylines: polylines ?? this.polylines,
    followLocation  : followLocation ?? this.followLocation,
    // markers  : markers ?? this.markers,
    centralLocation : centralLocation ?? this.centralLocation,
    drawRoute : drawRoute ?? this.drawRoute,
  );
}
