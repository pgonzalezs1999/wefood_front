import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wefood/types.dart';

class SearchFiltersCubit extends Cubit<Filters> {

  SearchFiltersCubit(): super(Filters());

  void setMaximumPrice(double? value) {
    Filters updatedState = state;
    updatedState.maximumPrice = value;
    emit(updatedState);
  }

  void setStartTime(TimeOfDay? value) {
    Filters updatedState = state;
    updatedState.startTime = value;
    emit(updatedState);
  }

  void setEndTime(TimeOfDay? value) {
    Filters updatedState = state;
    updatedState.endTime = value;
    emit(updatedState);
  }

  void setOnlyToday(bool value) {
    Filters updatedState = state;
    updatedState.onlyToday = value;
    emit(updatedState);
  }

  void setOnlyAvailable(bool value) {
    Filters updatedState = state;
    updatedState.onlyAvailable = value;
    emit(updatedState);
  }

  void setVegan(bool value) {
    Filters updatedState = state;
    updatedState.vegan = value;
    emit(updatedState);
  }

  void setVegetarian(bool value) {
    Filters updatedState = state;
    updatedState.vegetarian = value;
    emit(updatedState);
  }

  void setJunk(bool value) {
    Filters updatedState = state;
    updatedState.junk = value;
    emit(updatedState);
  }

  void setDessert(bool value) {
    Filters updatedState = state;
    updatedState.dessert = value;
    emit(updatedState);
  }
}