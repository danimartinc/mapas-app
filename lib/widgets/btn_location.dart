part of 'widgets.dart';

//Widget para renderizar el botón que al seleccionar situa al usuario en el centro del mapa respecto a su ubicación actual

class BtnLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //Instancio el MapBloc, lo obtengo desde el context
    final mapBloc = BlocProvider.of<MapBloc>(context);
    //Instancio el MyLocationBloc, lo obtengo desde el context
    final myLocationBloc = BlocProvider.of<MyLocationBloc>(context);

    return Container(
      margin: EdgeInsets.only( bottom: 10 ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
          icon: Icon( Icons.my_location, color: Colors.black87 ),
          //Disparamos el método
          onPressed: () {
            //Obtenemos la última ubicación
            final destination = myLocationBloc.state.location;
            mapBloc.moveCamera( destination! );
          },
        ),
      ),
    );
  }
}
