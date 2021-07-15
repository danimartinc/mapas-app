part of 'widgets.dart';

//Clase para renderizar la barra de búsqueda
class SearchBar extends StatelessWidget {

  @override
  Widget build( BuildContext context ) {

    //BlocBuilder, para disparar o no el renderizado de la barra de búsqueda
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        //Compruebo que si el usuario tiene activado la búsqueda manual
        if ( state.manualSelection ) {
          //En caso qué no esté seleccioanda, muestro un Widget vacio
          return Container();
        } else {
          //FadeInDown, introducimos una aminación en la que entre el Widget desde la parte de arriba
          return FadeInDown(
            duration: Duration( milliseconds: 300 ),
            //Renderizamos la barra de búsqueda
            child: buildSearchbar( context )
          );
        }

      },
    );

  }

  //Método que devuelve un Widget
  Widget buildSearchbar(BuildContext context) {

    //Mediante MediaQuery, obtengo el ancho de pantalla disponible del dispositivo
    final width = MediaQuery.of(context).size.width;

    //Instancio el locationBloc, lo obtengo desde el context
    final locationBloc = BlocProvider.of<MyLocationBloc>(context);
    //Instancio el SearchBloc, lo obtengo desde el context
    final searchBloc = BlocProvider.of<SearchBloc>(context);


    //TODO: SafeArea() explicacion
    return  SafeArea(
      //
      child: Container(
        padding: EdgeInsets.symmetric( horizontal: 30 ),
        width: width,
        //GestureDetector(), permite saber cuando el usuario selecciona la barra de búsqueda
        child: GestureDetector(
          onTap: () async {
            final proximity = locationBloc.state.location;
            //Historial de búsqueda, List<SearchResult>
            final history   = searchBloc.state.history;
          
            //Almaceno el resultado de tipo  SearchResult
            //ShowSearch() permite obtener un SearchDelegate, con caja de búsqueda, redirigir a la página anterior, etc...
            final result = await showSearch( 
              context: context,
              //Envio la proximidad del usuario mediante la ubicación
              delegate: SearchDestination( proximity!, history ) 
            );

            //Llamada al método returnSearch
            this.returnSearch( context, result! );

          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            width: double.infinity,
            child: Text('¿Dónde quieres ir?', style: TextStyle( color: Colors.black87 )),
            //Se aplica un estilo
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular( 100 ),
              //List que contiene las sombras
              boxShadow: <BoxShadow> [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  //Permite mover el Widget de pposición respecto a los ejes X-Y
                  offset: Offset( 0, 5 )
                )
              ]
            ),
          ),
        )
      ),
    );

  }

 //Método 
 Future returnSearch( BuildContext context, SearchResult result ) async {

   //Instancio el SearchBloc, lo obtengo desde el context
    final searchBloc   = BlocProvider.of<SearchBloc>(context);
    //Instancio el mapBloc, lo obtengo desde el context
    final mapBloc      = BlocProvider.of<MapBloc>(context);
    //Instancio el mapBloc, lo obtengo desde el context
    final locationBloc = BlocProvider.of<MyLocationBloc>(context);

    //Implementamos el trafficService
    final trafficService = new TrafficService();
    
    print( 'cancelo: ${ result.unsubscribe }' );
    print( 'manual: ${ result.manualLocation }' );

    //Comprobamos que si el usuario cancela la búsqueda, en este caso no devolvemos nada y cancelamos el procedimiento
    if ( result.unsubscribe ) return;

    //Si el usuario selecciona la búsqueda manual
    if ( result.manualLocation! ) {
      //Disparo el evento OnEnableManualMarker(), para activar el marcador manual
      searchBloc.add( OnEnableManualMarker() );
      return;
    }

    calculatingAlert(context);

    //Obtengo el punto inicial como mi ubicación actual del state
    final initialPosition  = locationBloc.state.location;
    //Coordenadas de destino de la ruta, que es el punto en el que se encuentra el marcador en el centro de la pantalla
    //Obtengo la posición desde el resultado, ya que solo se ejecuta si tengo un resultado
    final destination      = result.position;

    //Respuesta del trafficService
    final drivingResponse = await trafficService.getCoordsStartAndDestination( initialPosition!, destination! );

    //Decodificar los puntos de los geometries mediante polyline

    //Obtengo el código de la primera ubicación, se extrae el primer elemento de la lista
    final geometry  = drivingResponse.routes![0].geometry;
    //Duración del recorrido
    final duration  = drivingResponse.routes![0].duration;
    //Distancia del recorrido
    final distance  = drivingResponse.routes![0].distance;
    //Nombre del destino del recorrido
    //final destinationName = reverseQueryResponse.features[0].text;

    //Decodificar los puntos de los geometries mediante el paquete polyline 
    //precision: 6, sabemos que es 6 dado que viene de 6 posiciones decimales en la respuesta del MapBox, daod que en el trafficService trabajamos con polyline6
    //Tan solo extraemos el decodedCoords
    final points = Poly.Polyline.Decode( encodedString: geometry, precision: 6 );


    //Listado de latitud y longitud, los cuales transformo mediante un map()
    final List<LatLng> coordsRoute = points.decodedCoords!.map(
      //Devuelvo una nueva instancia de pares LatLng, donde la primera posión dle map contine la latitud, la segunda la longitud
      ( point ) => LatLng( point[0], point[1] )
      //Mediante toList(), lo transformo en una lista
    ).toList();

    
    //Disparamos el evento del mapBloc cuando seleccionamos el botón de Confirmar destino
    mapBloc.add( OncreateStartAndDestinationRoute( coordsRoute, distance!, duration! ) );
    //Cierro el popup del ShowDialog, el cual se cierra cuando tenemos ya marcado el polyline de la ruta
    Navigator.of(context).pop();

    //Agregar ubicaicñon al historial de búsqueda
    searchBloc.add( OnAddHistory( result ) );

 }

}