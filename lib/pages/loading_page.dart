import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
//Helpers
import 'package:mapas_app/helpers/helpers.dart';
//Pages
import 'package:mapas_app/pages/map_page.dart';
import 'package:mapas_app/pages/access_gps_page.dart';


//Preloader, se renderiza cuando se carga la app, ya que es la clase encargada de revisar si tenemos todos los permisos activados
//Si ocurre un error o faltan permisos envio el usuario al AcessGpsPage
//StatefulWidget, necesitamso controlar es estado del StatefulWidget, ya que necesitamso un listener que escuche los cambios de la app para cuando retorne el usuario
class LoadingPage extends StatefulWidget {

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

//WidgetsBindingObserver, permite detectar estado de la app cuando se suspende o se reanuda
class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver  {

  @override
  void initState() {
    //Inicializamos la unstancia del Observable, mediante this está escuchando si se prodicen cambios en el WidgetsBindingObserver 
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    //Elimino la instancia del Observable, para liberar memoria, mediante this está escuchando si se prodicen cambios
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  
  //Nos permite detectar cuando se produce un cambio en la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{

      //Comprobamos que si el state está en resumed
      if ( state == AppLifecycleState.resumed ) {
        //Comprobamos que si tenemos acceso al GPS
        if ( await GeolocatorPlatform.instance.isLocationServiceEnabled() ) {
          //Navegación para redigir al MapPage, ya que tengo todos los permisos activados de GPS y GPS activado
          //pushReplacementNamed(), evitamos que el usuario pueda retroceder a la página anterior
          //Realizamos la navegación mediante el helper navigateMapFadeIn()
          Navigator.pushReplacement(context, navigateMapFadeIn(context, MapPage() ) );
        }
      }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: this.checkGPSAndLocation(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          //Comprobamos que si tenemos información
           if ( snapshot.hasData ) {
             //Wdiget con la información
            return Center(child: Text( snapshot.data ) );
          } else {
            //CircularProgressIndicator(), permite indicar al usuario que se está cargando infromación 
            return Center(child: CircularProgressIndicator(strokeWidth: 2 ) );
          }
        }, 
      ),
   );
  }

  Future checkGPSAndLocation( BuildContext context ) async {

    //Para comprobar que tenemos acceso y permisos para el GPS. Obtenemos el status isGranted, que indica que el permiso está activado
    final permitGPS = await Permission.location.isGranted;
    //GPS está activo, habilitamos el LocationService del Geolocator e inicicalizamos la instancia
    final activeGPS = await GeolocatorPlatform.instance.isLocationServiceEnabled();

    //Comprobamos que si tenemos acceso al GPS y este se encuentra activo 
    if ( permitGPS && activeGPS ) {
      //Navegación para redigir al MapPage, ya que tengo todos los permisos activados de GPS y GPS activado
      //pushReplacementNamed(), evitamos que el usuario pueda retroceder a la página anterior
      //Realizamos la navegación mediante el helper navigateMapFadeIn()
      Navigator.pushReplacement(context, navigateMapFadeIn(context, MapPage() ) );
      return '';
    //En caso de no tener acceso al GPS
    } else if ( !permitGPS ) {
      Navigator.pushReplacement(context, navigateMapFadeIn(context, AccessGpsPage() ) );
      return 'Es necesario habilitar el permiso de GPS';
    } else {
      return 'Active el GPS';
    }

  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
