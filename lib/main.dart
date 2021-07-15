import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//Blocs
import 'package:mapas_app/bloc/my_location/my_location_bloc.dart';
import 'package:mapas_app/bloc/map/map_bloc.dart';
import 'package:mapas_app/bloc/search/search_bloc.dart';
//Pages
import 'package:mapas_app/pages/access_gps_page.dart';
import 'package:mapas_app/pages/loading_page.dart';
import 'package:mapas_app/pages/map_page.dart';




 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //TODO: Explicacion
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: ( _ ) => MyLocationBloc() ),
        BlocProvider(create: ( _ ) => MapBloc() ),
        BlocProvider(create: ( _ ) => SearchBloc() ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        //Página de inicio
        //home: LoadingPage(),
        home: AccessGpsPage(),
        //Mapa de rutas para la navegación de nuestra app
        routes: {
          'map'        : ( _ ) => MapPage(),
          'loading'    : ( _ ) => LoadingPage(),
          'access_gps' : ( _ ) => AccessGpsPage(),
        },
      ),
    );
  }
}