import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
//Models
import 'package:mapas_app/models/search_response.dart';
import 'package:mapas_app/models/search_result.dart';
//Providers
import 'package:mapas_app/services/traffic_service.dart';



//TODO: Explicacion SearchDElegate
//Clase que implmenta el SearchDelegate, que permite
class SearchDestination extends SearchDelegate<SearchResult> {

  @override
  //Texto que se muestra en el Label de la barra de búsqueda
  final String searchFieldLabel;
  //Instanciamos el TrafficService
  final TrafficService _trafficService;
  final LatLng proximity;
  final List<SearchResult> history;

  //Constructor
  SearchDestination( this.proximity, this.history )
    //Inicializo el label del texto que queremos que muestre la barra de búsqueda
    : this.searchFieldLabel = 'Buscar...',
      //Inicializo el service, ya que como es un Singleton siempre obtengo la misma instancia
      this._trafficService = new TrafficService();


  //Método que retorna una lista de Widgets con el icono que aparece al final de la barra de búsqueda
  @override
  List<Widget> buildActions(BuildContext context) {

    //Botón que borra el texto que ha introducido el usuario por teclado
    return [
      IconButton(
        icon: Icon( Icons.clear ),
        //Limpio el cuadro de texto, enviando un String vacio en la query, está incluido en el SearchDelegate
        onPressed: () => this.query = ''
      )
    ];
  }

  //Método que retorna un Widget con el icono que aparece al inicio de la barra de búsqueda
  @override
  Widget buildLeading(BuildContext context) {

    //Inicializo una instancia de searchResult
    final searchResult = SearchResult(unsubscribe: true );

    //Botón que permite retornar al MapPage sin realizar la búsqueda, en el caso de que el usuario lo cancele
    return IconButton(
      icon: Icon( Icons.arrow_back_ios ),
      //Disparo el close() que cierra la barra de búsuqedas
      onPressed: () => this.close(context, searchResult )
    );
  }

  //Método que cuando el usuario selecciona enter, muestra los resultados finales y cierra el teclado del dispositivo
  @override
  Widget buildResults(BuildContext context) {
      //Retorno el método _buildSuggestionsResults()
      return this._buildSuggestionsResults();

    //Realizo la llamada al servicio
  //  this._trafficService.getResultsByQuery( this.query.trim(), proximity );
  }

  //Método que muestra las sugerencias respecto al texto que está escribiendo el usuario, devuelve un Widget
  @override
  Widget buildSuggestions(BuildContext context) {

    //Compruebo que si la query está vacía, no ha escrito todavía el usuario o ha borrado el contenido
    if ( this.query.length == 0 ) {
      //Permite colocar el marcador manualmente y muestra el historial, con las opciones buscadas previamente
      return ListView(
        children: [

          ListTile(
            leading: Icon( Icons.location_on ),
            title: Text('Colocar ubicación manualmente'),
            //Dispara la acción para situar un marcador de ubicación de forma manual en el mapa
            onTap: () {
              //Cerramos el SearchDelegate
              //Segundo argumento, valor de retorno que trabaja con Future génerico mediante el showSearch, de tipo SearchResult
              this.close( context, SearchResult( unsubscribe: false, manualLocation: true ) ); 
            },
          ),

          //Muestro el historial de búsqueda
          //Mediante map(), mapeo la respuesta del List<SearchResult> history y lo muestro en ListTile()
          ...this.history.map(
            ( result ) => ListTile(
              leading: Icon( Icons.history ),
              title: Text( result.destinationName! ),
              subtitle: Text( result.description! ),
              //Disparamos el click
              onTap: () {
                this.close(context, result );
              },
            )
          ).toList()


        ],
      );

    }

    //Si no es el caso, llamo al método para que muestre las sugerencias
    return this._buildSuggestionsResults();

  }

  //Método que retorna un Widget con los resultados de las sugerencias respecto el texto que introduce el usuario en la caja de búsqueda
  Widget _buildSuggestionsResults() {
    
    //Compruebo que si la queri está vacía, devuelvo un Widget vacío
    if ( this.query == 0 ) {
      return Container();
    }

    //Implemento el getSuggestionsByQuery() con el Debouncer y emitir eventualmente los resultados cuando el usuario deje de escribir
    this._trafficService.getSuggestionsByQuery( this.query.trim(), this.proximity );
    
    //Implmentamos un DebounceTime, para evitar que no se dispare una petición GET cada vez que el usuario introduce un caracter en la barra de búsqueda
    //Implemento el StreamBuilder, para controlar sus emisiones para que solo se renderize de manera controlada
    //Realizo la petición para retornar el Future 
    return StreamBuilder(
      //Retorna un Stream cada ves que se llama al método que contiene el resultado de las sugerencias
      stream: this._trafficService.suggestionsStream,
      builder: (BuildContext context, AsyncSnapshot<SearchResponse> snapshot) {

        //Compruebo que si NO tenemos data en el snapshot
        if ( !snapshot.hasData ) {
          return Center(child: CircularProgressIndicator());
        }

        //Extraemos los lugares desde ladata del snapshot
        final places = snapshot.data!.features;

        //Compruebo que si no hay lugares que coincidan con la búsqueda
        if ( places!.length == 0 ) {
          return ListTile(
            title: Text('No hay resultados con $query'),
          );
        }

        return ListView.separated(
          //Longitud del ListView
          itemCount: places.length,
          //Separador de los elementos
          separatorBuilder: ( _ , i ) => Divider(), 
          itemBuilder: ( _, i ) {
            //Extraemos el lugar de la list de lugares
            final place = places[i];
            //Widget que retorna el itemBuilder()
            return ListTile(
              leading: Icon( Icons.place ),
              title: Text( place.textEs! ),
              subtitle: Text( place.placeNameEs! ),
              onTap: () {
                //Envio un objeto de tipo SearchResult() cuando selecciono el destino en la barra de búsqueda
                this.close(context,  SearchResult(
                  unsubscribe: false,
                  manualLocation: false,
                  //Posición, en PapBox vienen las coordenadas al contrario, primero longitud y segundo latitud
                  position: LatLng( place.center![1], place.center![0]),
                  destinationName: place.textEs,
                  description: place.placeNameEs,
                ));

              },
            );
          }, 
        );
    
      },
    );

  }

}