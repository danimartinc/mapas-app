import 'dart:async';
// Creditos
// https://stackoverflow.com/a/52922130/7834829

//Implmentamos un DebounceTime, para evitar que no se dispare una petición GET cada vez que el usuario introduce un caracter en la barra de búsqueda
//Controla información relacionada a la barra de búsqueda
class Debouncer<T> {

  //El debouncer se emite durante el tiempo que le indiquemos en el duration
  Debouncer({ 
    required this.duration, 
    this.onValue 
  });

  final Duration duration;

  void Function(T value)? onValue;

  T? _value;
  Timer? _timer;
  
  T get value => _value!;

  set value(T val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onValue!(_value!));
  }  
}