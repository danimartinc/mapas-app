import 'package:flutter/material.dart';
//Pages
import 'package:mapas_app/pages/access_gps_page.dart';
import 'package:mapas_app/pages/loading_page.dart';
import 'package:mapas_app/pages/map_page.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      //Página de inicio
      //home: LoadingPage(),
      home: AccessGpsPage(),
      //Mapa de rutas para la navegaciñon de nuestra app
      routes: {
        'map'        : ( _ ) => MapPage(),
        'loading'    : ( _ ) => LoadingPage(),
        'access_gps' : ( _ ) => AccessGpsPage(),
      },
    );
  }
}