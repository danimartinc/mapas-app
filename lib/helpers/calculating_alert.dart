part of 'helpers.dart';


//Función que permite mostrar una alerta
void calculatingAlert( BuildContext context ) {

  //TODO: Añadir CircularProgressIndicator
  //En caso de que el dispositivo sea un Android
  if ( Platform.isAndroid ) {
    //Mostramos un Dialog
    showDialog(
      context: context,
      //Disparamos el contenido del AlertDialog
      builder: (context) => AlertDialog(
        title: Text('Espere por favor'),
        content: Text('Calculando ruta'),
      ),
    );

  } else {
    //En caso de que el dispositivo sea un IOs
    showCupertinoDialog(
      context: context,
      //Disparamos el contenido del AlertDialog 
      builder: (context) => CupertinoAlertDialog(
        title: Text('Espere por favor'),
        content: CupertinoActivityIndicator(),
      ),
    );

  }


}
