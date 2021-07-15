import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_app/helpers/helpers.dart';


//Models
import 'package:mapas_app/models/search_result.dart';

//Blocs
import 'package:mapas_app/bloc/map/map_bloc.dart';
import 'package:mapas_app/bloc/my_location/my_location_bloc.dart';
import 'package:mapas_app/bloc/search/search_bloc.dart';
import 'package:polyline_decoded_kur/polyline.dart' as Poly;

//Search
import 'package:mapas_app/search/search_destination.dart';

//Providers
import 'package:mapas_app/services/traffic_service.dart';

//Helpers
import 'package:mapas_app/helpers/helpers.dart'; 

part 'btn_my_route.dart';
part 'btn_location.dart';
part 'btn_follow_location.dart';
part 'manual_marker.dart';
part 'searchbar.dart';