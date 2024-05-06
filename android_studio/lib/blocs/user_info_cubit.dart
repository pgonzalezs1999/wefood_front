import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wefood/models/models.dart';
import 'package:http/http.dart' as http;

class UserInfoCubit extends Cubit<BusinessExpandedModel> {

  UserInfoCubit(): super(BusinessExpandedModel.empty());

  void setRealName({
    required String realName,
    required String realSurname,
  }) {
    BusinessExpandedModel updatedState = state;
    updatedState.user.realName = realName;
    updatedState.user.realSurname = realSurname;
    emit(updatedState);
  }

  void setUsername(String value) {
    BusinessExpandedModel updatedState = state;
    updatedState.user.username = value;
    emit(updatedState);
  }

  void setPicture(Image image) {
    BusinessExpandedModel updatedState = state;
    updatedState.image = image;
    emit(updatedState);
  }

  void setUser(UserModel value) {
    BusinessExpandedModel updatedState = state;
    updatedState.user = value;
    emit(updatedState);
  }

  void setBusiness(BusinessModel value) {
    BusinessExpandedModel updatedState = state;
    updatedState.business = value;
    emit(updatedState);
  }

  void setBusinessName(String? value) {
    BusinessExpandedModel updatedState = state;
    updatedState.business.name = value;
    emit(updatedState);
  }

  void setBusinessDescription(String? value) {
    BusinessExpandedModel updatedState = state;
    updatedState.business.description = value;
    emit(updatedState);
  }

  void setBusinessDirections(String? value) {
    BusinessExpandedModel updatedState = state;
    updatedState.business.directions = value;
    emit(updatedState);
  }

  void setBusinessLatLng(LatLng? latLng) {
    BusinessExpandedModel updatedState = state;
    updatedState.business.latitude = latLng?.latitude;
    updatedState.business.longitude = latLng?.longitude;
    emit(updatedState);
  }
}