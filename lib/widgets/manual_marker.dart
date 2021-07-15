part of 'widgets.dart';


class ManualMarker extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    //Mediante BlocBuilder, renderizamos el marcador manual de manera condicional, ya que por defecto permanece deshabilitado
    return  BlocBuilder<SearchBloc, SearchState>(
      //Obtenemos el state actual mediante el SearchBloc
      builder: (context, state) {
        
        //Comprobamos que si el usuario ha activado la selección manual
        if ( state.manualSelection ) {
          return _BuildManualMarker();
        } else {
          //En caso que la selección manual esté desactivada, no mostramos nada por lo que mostramso un Container sin contenido
          return Container();
        }

      },
    );
    
  }
  
}


//Clase para renderizar el Widget del marcador manual
class _BuildManualMarker extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    //Mediante MediaQuery, obtengo el ancho de pantalla disponible del dispositivo
    final width = MediaQuery.of(context).size.width;

    //Instancio el SearchBloc, lo obtengo desde el context
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    
    //Stack, dado que es necesario implementar Widgets sobre el MapPage
     return Stack(
      children: [     
        //Botón para retroceder
        Positioned(
          top: 70,
          left: 20,
          //Introducimos una animación en la que entre el elemento desde la izquierda
          child: FadeInLeft(
            duration: Duration(milliseconds: 150),
            child: CircleAvatar(
              maxRadius: 25,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon( Icons.arrow_back, color: Colors.black87 ),
                //Dispara el proceso de cancelar la búsqueda manual
                onPressed: () {
                  searchBloc.add( OnDisableManualMarker() );
                }
              ),
            ),
          )
        ),
        
        //Lo situamos en el centro de la pantalla
        Center(
          //Transform.translate, Widget que nos permite posicionar el Widget en la pantalla respecto a los ejes X-Y 
          child: Transform.translate(
            offset: Offset(0, -12),
            //BounceInDown, introducimos una animación en la que el elemento rebota al llegar a su posición
            child: BounceInDown(
              from: 200,
              child: Icon( Icons.location_on, size: 50 )
            )
          ),
        ),

        //Botón para confirmar el destino
        Positioned(
          bottom: 70,
          left: 40,
          child: FadeIn(
            child: MaterialButton(
              minWidth: width - 180,
              child: Text('Confirmar destino', style: TextStyle( color: Colors.white ) ),
              color: Colors.black,
              //Redondeamos lso bordes del botón
              shape: StadiumBorder(),
              elevation: 0,
              splashColor: Colors.transparent,
              //Disparamos el método getCoordsStartAndDestination para confirmar el destino
              onPressed: () {
                this.calculateDestinationRoute( context );
              }
            ),
          )
        ),


       ],
    );
  }

  //Método que contiene 
  void calculateDestinationRoute( BuildContext context ) async {
    
    //Mostramos el ShowDialog
    //En caso de querer personalizar los mensajes se reciben como argumento
    calculatingAlert(context);

    //Instancio el SearchBloc, lo obtengo desde el context
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    //Instancio el mapBloc, lo obtengo desde el context
    final mapBloc = BlocProvider.of<MapBloc>(context);
    //Instancio el mapBloc, lo obtengo desde el context
    final locationBloc = BlocProvider.of<MyLocationBloc>(context);


    //Implementamos el trafficService
    final trafficService = new TrafficService();
  
    //Obtengo el punto inicial como mi ubicación actual del state
    final initialPosition  = locationBloc.state.location;
    //Coordenadas de destino de la ruta, que es el punto en el que se encuentra el marcador en el centro de la pantalla
    final destination      = mapBloc.state.centralLocation;

    //Obtengo las coordenadas del punto inicial y el destino
    final trafficResponse = await trafficService.getCoordsStartAndDestination(initialPosition!, destination! );

    //Decodificar los puntos de los geometries mediante polyline

    //Obtengo el código de la primera ubicación, se extrae el primer elemento de la lista
    final geometry  = trafficResponse.routes![0].geometry;
    //Duración del recorrido
    final duration  = trafficResponse.routes![0].duration;
    //Distancia del recorrido
    final distance  = trafficResponse.routes![0].distance;
    //Nombre del destino del recorrido
    //final destinationName = reverseQueryResponse.features[0].text;

    //Decodificar los puntos de los geometries mediante el paquete polyline 
    //precision: 6, sabemos que es 6 dado que viene de 6 posiciones decimales en la respuesta del MapBox, daod que en el trafficService trabajamos con polyline6
    //Tan solo extraemos el decodedCoords
    final points = Poly.Polyline.Decode( encodedString: geometry, precision: 6 ).decodedCoords;

    final temp = points;

    //Listado de latitud y longitud, los cuales transformo mediante un map()
    final List<LatLng> coordsRoute = points!.map(
      //Devuelvo una nueva instancia de pares LatLng, donde la primera posión dle map contine la latitud, la segunda la longitud
      ( point ) => LatLng( point[0], point[1] )
      //Mediante toList(), lo transformo en una lista
    ).toList();

    //Disparamos el evento del mapBloc cuando seleccionamos el botón de Confirmar destino
    mapBloc.add( OncreateStartAndDestinationRoute( coordsRoute, distance!, duration! ) );

    //Cierro el popup del ShowDialog, el cual se cierra cuando tenemos ya marcado el polyline de la ruta
    Navigator.of(context).pop();
    //Deshabilitar el botón de Confirmar destino, marcador del punto y el botón para retroceder a la página anterior
    searchBloc.add( OnDisableManualMarker() );
  }
}