part of 'search_bloc.dart';

//Clase abstracta de la que extendemos los eventos propios de la clase
@immutable
abstract class SearchEvent {}

//Evento que se dispara al activar la búsqueda manual
class OnEnableManualMarker extends SearchEvent {}

//Evento que se dispara al desactivar la búsqueda manual
class OnDisableManualMarker extends SearchEvent {}

//Evento para añadir el historial de búsqueda
class OnAddHistory extends SearchEvent {
  //Resultado de la búsqueda
  final SearchResult result;
  //Constructor
  OnAddHistory(this.result);

}