part of 'widgets.dart';

//Widget para renderizar el botón que al seleccionar situa al usuario en el centro del mapa respecto a su ubicación actual

class BtnMyRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //Instancio el MapBloc, lo obtengo desde el context
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: EdgeInsets.only( bottom: 10 ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
          icon: Icon( Icons.more_horiz, color: Colors.black87 ),
          //Disparamos el método
          onPressed: () {
            //Disparo el evento que cambia el valor del boolean para msotrar/ocultar el polyline
            mapBloc.add( OnMarkRoute() );
          },
        ),
      ),
    );
  }
}
