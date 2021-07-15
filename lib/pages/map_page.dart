import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//Blocs
import 'package:mapas_app/bloc/my_location/my_location_bloc.dart';
import 'package:mapas_app/bloc/map/map_bloc.dart';
//Widgets
import 'package:mapas_app/widgets/widgets.dart';

//Home de la app, para poder acceder es necesario tener acceso al GPS, la localización del usuario, y activo el servicio GPS
//StatefulWidget, dado que solo lo ejecutamos una vez
class MapPage extends StatefulWidget {

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  //Listener
  @override
  void initState() {
    //Instancio el MyLocationBloc, lo obtengo desde el context
    final locationBloc = BlocProvider.of<MyLocationBloc>(context);
    //Inicializo el seguimiento de localización del usuario
    locationBloc.startMonitoring();
    super.initState();
  }

  @override
  void dispose() {
    //Instancio el MyLocationBloc, lo obtengo desde el context
    final locationBloc = BlocProvider.of<MyLocationBloc>(context);
    locationBloc.cancelMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //stack, permite colocar un Widget sobre otro
      body: Stack(
        children: [

          BlocBuilder<MyLocationBloc, MyLocationState>(
            builder: ( _ , state) => createMap(state),
          ),

          //TODO: Hacer el Toggle cuando estoy manualmnete o no
          //Dentro de un Stack, permite ubicar el Wdiget en la posición que se desee
          Positioned(
            top: 15,
            child: SearchBar()
          ),

          ManualMarker()

        ],
      ),
  

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //Botón que al seleccionar situa al usuario en el centro del mapa respecto a su ubicación actual
          BtnLocation(),

          BtnFollowLocation(),

          BtnMyRoute(),
        ],
      ),
   );
  }

  
  //Método que nos permite definir el Widget del mapa, la cual se dispara tan solo si se modifica el state
  Widget createMap( MyLocationState state ) {

    //Comprobamos que si no existe la última ubicación conocida del usuario
    if( !state.existsLocation ) return Center(child: Text('Ubicando...'));

    //Implementamos la instancia del MapBloc, a través del context
    final mapBloc = BlocProvider.of<MapBloc>(context);

    //Agrego la nueva dirección al polyline, disparando el evento que indica que se ha encontrado una nueva localización
    //Se emite cada vez que añade una nueva localización
    mapBloc.add( OnNewLocation( state.location! ) );

    //Posición de la camara de GoogleMaps
    final cameraPosition = new CameraPosition(
      //Ubicación, latitud y longitud
      target: state.location!,
      zoom: 15
    );

    //BlocBuilder(), nos permite renderizar de nuevo el Widget cuando el usuario selecciona el botón Confirmar destino
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, __ ) {
        //TODO: Mirar propiedades map
        //Si se conoce una última ubicación del usuario, mostramos el mapa de GoogleMap
        return GoogleMap(
          //Posición inicial de la cámara
          initialCameraPosition: cameraPosition,
          //Tipo de mapa
          mapType: MapType.normal,
          //Punto que indica la posición actual del usuario
          myLocationEnabled: true,
          //Reubica al usuario en pantalla en la ubicación actual
          myLocationButtonEnabled: false,
          //Desactivamos opciones del zoom
          zoomControlsEnabled: false,
          //Dispara el método para inicilizar el map
          onMapCreated: mapBloc.initMapa,
          //Polylines, listado que tenemos en el State, que permtien trazar una linea mediante dos puntos de coordenadas dadas
          //Almacena un listado de las coordenadas con las posiciones del usuario
          //toSet(), para mostrar un tipo set()
          polylines: mapBloc.state.polylines!.values.toSet(),
          //markers: mapBloc.state.markers.values.toSet(),
          //onCameraMove, dispara el evento cuando el mapa se mueve,disparando el cameraPosition
          onCameraMove: ( cameraPosition ) {
            //cameraPosition.target = LatLng central del mapa
            mapBloc.add( OnUserMovedMap( cameraPosition.target ) );
          },
        );
      },
    );
  }

}