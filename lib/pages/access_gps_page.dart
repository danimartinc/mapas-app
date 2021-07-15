import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//StatefulWidget, necesitamso controlar es estado del StatefulWidget, ya que necesitamso un listener que escuche los cambios de la app para cuando retorne el usuario
class AccessGpsPage extends StatefulWidget {

  @override
  _AccessGpsPageState createState() => _AccessGpsPageState();
}

//WidgetsBindingObserver, permite detectar estado de la app cuando se suspende o se reanuda
class _AccessGpsPageState extends State<AccessGpsPage> with WidgetsBindingObserver {

  bool popup = false;

  //
  @override
  void initState() {
    //Inicializamos la unstancia del Observable, mediante this está escuchando si se prodicen cambios en el WidgetsBindingObserver 
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  //
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
    if ( state == AppLifecycleState.resumed && !popup ) {
      //Comprobamos que tenemos los permisos de localización garantizados
      //isGranted regresa un Future Boolean por lo que podemos aplicar el async-await
      if ( await Permission.location.isGranted  ) {
        //Redirigo hacia la page del loading
        Navigator.pushReplacementNamed(context, 'loading');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Indicamos al usuario que para usar la aplicación es necesario activar GPS
            Text( 'Es necesario el GPS para utilizar este app'),

            MaterialButton(
              child: Text('Solicitar Acceso', style: TextStyle( color: Colors.white )),
              color: Colors.black,
              //Redondeamos los bordes
              shape: StadiumBorder(),
              elevation: 0,
              //Modificamos el splash
              splashColor: Colors.transparent,
              onPressed: () async {
                popup = true;
                //Extraemos el status del permiso del GPS
                //Mediante request(), siempre solicito el permiso ya que devuelve un Future
                final status = await Permission.location.request();
                await this.accessGPS( status );

                popup = false;
              }  
            )
          ],
        )
     ),
   );
}

 Future accessGPS( PermissionStatus status )  async {
  
  switch ( status ) {
    
    case PermissionStatus.granted:
      //En el caso de que se otorge el permiso, redirigo hacia la otra pantalla
      await Navigator.pushReplacementNamed(context, 'loading' );
      break;
    
    //En caso de que se encuentre en uno de los siguientes estados, abro las settings
    case PermissionStatus.limited:
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
    case PermissionStatus.permanentlyDenied:
    openAppSettings();
  }
    
  }
}