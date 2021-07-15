part of 'search_bloc.dart';

//Clase inmutable
@immutable
class SearchState {

  //Nos permite concoer si está activada la búsqueda manual
  //Si es true, mostramos los Widgets relacionados, en caso de false, mostramos la barra de búsqueda
  final bool manualSelection;
  //Historial de la barra de búsquedas
  final List<SearchResult> history;

  SearchState({
    this.manualSelection = false,
    List<SearchResult>? history
    //Inicializo el historial
  }) : this.history = ( history == null ) ? [] : history;

  //TODO: Explicación
  SearchState copyWith({
    bool? manualSelection,
    List<SearchResult>? history
  }) => SearchState(
    //Mantenemos los valroes del state actual
    manualSelection : manualSelection ?? this.manualSelection,
    history         : history ?? this.history,
  );

}

class SearchInitial extends SearchState {}
