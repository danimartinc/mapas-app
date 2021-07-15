import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

//Models
import 'package:mapas_app/models/search_result.dart';


part 'search_event.dart';
part 'search_state.dart';

//
class SearchBloc extends Bloc<SearchEvent, SearchState> {

  //Constructor
  SearchBloc() : super(SearchState());

  //Implementamos funciones generadoras mediante async*
  @override
  Stream<SearchState> mapEventToState( SearchEvent event, ) async* {
    
    //Comprobamos que si el evento que recibo es de tipo OnEnableManualMarker
    if ( event is OnEnableManualMarker ) {
      //Emito un nuevo state, manteniendo la información del state actual, y activando la búsqueda manual
      yield state.copyWith( manualSelection: true );

    //Comprobamos que si el evento que recibo es de tipo OnDisableManualMarker
    } else if ( event is OnDisableManualMarker ) {
      //Emito un nuevo state, manteniendo la información del state actual, y desactivando la búsqueda manual
      yield state.copyWith( manualSelection: false );

    //Comprobamos que si el evento que recibo es de tipo OnDisableManualMarker
    } else if ( event is OnAddHistory ) {

      //TODO: Extraer lógica

      //Comprobamos que si el evento que quiero agregar, existe previamente en el historial
      final exists = state.history.where(
        //Si ambos nombres son iguales, indicamos que existen
        (result) => result.destinationName == event.result.destinationName
      ).length;

      //En caso de devolver 0, no existe, entonces lo inserta
      if ( exists == 0 ) {
        //Le añado al nuevo historial, la copia del sate del historial actual y el resultado del evento
        final newHistorial = [...state.history, event.result];
        //Emito el evento con el historial, realizando una copia del historial actual y añadiendo los nuevos mensajes
        yield state.copyWith( history: newHistorial );
      }
      
    }
  }
}
