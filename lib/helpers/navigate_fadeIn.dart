//Indicamos que la clase forma parte de los Helpers
part of 'helpers.dart';

//Clase que nos permite realizar durante la navegación un animación fadeIn
//Segundo argumento, Widget al que quiero navegar, page
Route navigateMapFadeIn( BuildContext context, Widget page ) {
  //
  return PageRouteBuilder(
    //Dispara la función que permite redireccionar a la página que envio como argumento
    pageBuilder: ( _, __ , ___ ) => page,
    //Duracíon de la transicción entre páginas
    transitionDuration: Duration( milliseconds: 300 ),
    //Tercer argumento, animation secundario
    transitionsBuilder: ( context, animation, _, child ) {
      return FadeTransition(
        //Widget al que qurremos redirigir
        child: child,
        //Opacidad desde el punto que me encuentro al que quiero finalizar
        //Tween(), permite indicar entre que dos puntos realizamos la opacidad
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          //Indicamos la animación que queremos implementar
          CurvedAnimation( parent: animation, curve: Curves.easeOut )
        )
      );
    }  
  );

}