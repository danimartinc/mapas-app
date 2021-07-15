import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
//Models
import 'package:mapas_app/models/search_response.dart';
import 'package:mapas_app/models/traffic_response.dart';
//Helpers
import 'package:mapas_app/helpers/debouncer.dart';
//import 'package:mapa_app/models/reverse_query_response.dart';


//Service para controlar la información relacionada de la API de MapBox, recibiendo la ubicación final y la ubicación de destino
class TrafficService {

  //Implementa un patrón Singleton, por lo que al hacer refernecia a su instancia única siempre se utiliza la misma
  TrafficService._privateConstructor();
  //Copia estática de la instancia del TrafficService
  static final TrafficService _instance = TrafficService._privateConstructor();

  //Aplicamos un Factory Constructor, constructor privado para que el TrafficService implemente la instancia anterior
  //Cuando realizamos un new se llama a este constructor que retorna la instancia del TrafficService
  factory TrafficService(){
    return _instance;
  }

  //Nos permite realizar peticiones HTTP
  final _dio = new Dio();
  //Definición del debouncer, nos permite indicar el tiempo de espera que asignamos a la función antes de ejecutarla
  final debouncer = Debouncer<String>(duration: Duration(milliseconds: 400 ));

  //Implementamos el StreamController mediante el qué trabaja el getSuggestionsByQuery, que emite valores de tipo SearchResponse
  //Mediante broadcast() lo escucha todos los Widgets que está escuchando el Servicio
  //La información que fluye en el Stream es SearchResponse
  final StreamController<SearchResponse> _suggestionsStreamController = new StreamController<SearchResponse>.broadcast();
  //Getter del _suggestionsStreamController, que permite obtener sus valores
  Stream<SearchResponse> get suggestionsStream => this._suggestionsStreamController.stream;

  //Path del Endpoint de Mapbox para directions
  final _baseUrlDir = 'https://api.mapbox.com/directions/v5';
  //Path del Endpoint de Mapbox para geocoding
  final _baseUrlGeo = 'https://api.mapbox.com/geocoding/v5';
  //APIKey de la API de MapBox
  final _apiKey     = 'pk.eyJ1IjoiZGFuaW1hcnRpbmMiLCJhIjoiY2tyMXNtNWl3MjRwazMxcXBuZTFvb2ozOCJ9.Zi8Nmwt3sjOme7SBwAPXYg';


  //Método que retorna un Futurede tipo DrivingResponse con las coordenadas, que se dispara al seleccionar el botón de Confirmar destino
  //Recibe mediante argumentos la latitud y longitud de la ubicación de incio y la de destino
  Future<DrivingResponse> getCoordsStartAndDestination( LatLng initialPosition, LatLng destination ) async {

    //TODO: try-catch

    //Coordenadas que paso por parámetro en la petición
    final coordString = '${ initialPosition.longitude },${ initialPosition.latitude };${ destination.longitude },${ destination.latitude }';
    //URL de la petición 
    final url = '${ this._baseUrlDir }/mapbox/driving/$coordString';

    //Petición GET 
    //Configuramos los queryParams mediante un map y dio(), todos son obligatorios
    final resp = await this._dio.get( url, queryParameters: {
      'alternatives': 'true',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': this._apiKey,
      'language': 'es',
    });

    
    print( resp );

    //Convertimos la data de la respuesta de tipo DrivingResponse y lo mapeamos a formato JSON
    final data = DrivingResponse.fromJson( resp.data );

    return data;

  }

  //Propiedad Center, latitud y longitud a donde se quiere dirigir el usuario
  //Método que
  //Primer argumento, texto que el usuario introduce en la barra de búsqueda
  //Segundo argumento, proximity de tipo LatLng
  Future<SearchResponse> getResultsByQuery( String search, LatLng proximity ) async {

    print('Buscando!!!');

    //URL para realizar la petición GET
    final url = '${ this._baseUrlGeo }/mapbox.places/$search.json';

    try {

        //Almacenamos la respuesta a la petición GET
        final resp = await this._dio.get( url, queryParameters: {
          //queryParameters de la petición
          'access_token': this._apiKey,
          //Indicamos que complete automáticamente
          'autocomplete': 'true',
          'proximity'   : '${ proximity.longitude },${ proximity.latitude }',
          'language'    : 'es',
        });

        //Respuesta de tipo searchResponse, que contiene la dta de la petición GET
        final searchResponse = searchResponseFromJson( resp.data );
        return searchResponse;

    } catch (e) {
      //En caso de error, retorno un SearchResponse vacío, sin contenido, con los Features vacios
      return SearchResponse( features: [] );
    }

  }

  //Método que al indicarle el timpo especificado realiza la llamada al _suggestionsStreamController
  void getSuggestionsByQuery( String search, LatLng proximity ) {
    
    //El valor del debouncer es lo que concateno según escribe el usuario, 
    debouncer.value = '';
    //Función asíncrona qué llama al método getResultsByQuery()
    debouncer.onValue = ( value ) async {
      final results = await this.getResultsByQuery(value, proximity);
      this._suggestionsStreamController.add( results );
    };

    final timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      debouncer.value = search;
    });

    Future.delayed(Duration(milliseconds: 201)).then((_) => timer.cancel()); 

  }

 /* Future<ReverseQueryResponse> getCoordenadasInfo( LatLng destinoCoords ) async {

    final url = '${ this._baseUrlGeo }/mapbox.places/${ destinoCoords.longitude },${ destinoCoords.latitude }.json';

    final resp = await this._dio.get( url, queryParameters: {
      'access_token': this._apiKey,
      'language': 'es',
    });

    final data = reverseQueryResponseFromJson( resp.data );

    return data;


  }*/

  void dispose() {
    _suggestionsStreamController.close();
  }


}

