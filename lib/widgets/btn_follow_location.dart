part of 'widgets.dart';

//Widget para renderizar el botón que al seleccionar situa al usuario en el centro del mapa respecto a su ubicación actual
class BtnFollowLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //Es necesario volver a renderizar el botón mediante el BlocBuilder()
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) => this._createButton( context, state )
    );
  }


  //Método para crear el Widget del botón
  Widget _createButton( BuildContext context, MapState state ) {

    //Instancio el MapBloc, lo obtengo desde el context
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: EdgeInsets.only( bottom: 10 ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        maxRadius: 25,
        child: IconButton(
          icon: Icon(
            //Mediante un operador ternario muestro o no un icono distinto
            state.followLocation!
              //Si el icono está activado
              ? Icons.directions_run
              : Icons.accessibility_new,
            color: Colors.black87 
          ),
          //Disparamos el método
          onPressed: () {
            //Disparo el evento que sigue el recorrido del usuario por el polyline
            mapBloc.add( OnFollowLocation() );
          },
        ),
      ),
    );
    }
}