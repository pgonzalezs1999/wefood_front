import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocationCubit extends Cubit<LatLng?> {

  UserLocationCubit(): super(null);

  void set({
    required LatLng location,
  }) {
    emit(location);
  }

  void delete() {
    emit(null);
  }
}