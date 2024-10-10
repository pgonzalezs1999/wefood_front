import 'package:bloc/bloc.dart';
import 'package:wefood/models.dart';
import 'package:flutter/material.dart';
import 'package:wefood/types.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusinessBreakfastCubit extends Cubit<ProductModel?> {

  BusinessBreakfastCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }

  void delete() {
    emit(null);
  }
}

class BusinessLunchCubit extends Cubit<ProductModel?> {

  BusinessLunchCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }

  void delete() {
    emit(null);
  }
}

class BusinessDinnerCubit extends Cubit<ProductModel?> {

  BusinessDinnerCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }

  void delete() {
    emit(null);
  }
}

class FavouriteItemsCubit extends Cubit<List<ProductExpandedModel>?> {

  bool needsRefresh = false;

  FavouriteItemsCubit(): super(null);

  int _compareByDate(ProductExpandedModel a, ProductExpandedModel b) {
    return a.item.date!.compareTo(b.item.date!);
  }

  void set(List<ProductExpandedModel> list) {
    needsRefresh = false;
    list.sort(_compareByDate);
    emit(list);
  }

  void addItem(ProductExpandedModel item) {
    List<ProductExpandedModel>? updatedState = state;
    updatedState?.add(item);
    needsRefresh = true;
    emit(updatedState);
  }

  void removeItemByBusinessId(int businessId) {
    List<ProductExpandedModel> updatedState = state!;
    updatedState.removeWhere((i) => i.business.id == businessId);
    needsRefresh = true;
    emit(updatedState);
  }

  void setImageById({
    required int itemId,
    required ImageModel imageModel,
  }) {
    List<ProductExpandedModel> updatedState = state!;
    updatedState.firstWhere((i) => i.item.id == itemId).image = imageModel;
    emit(updatedState);
  }

  bool businessIsFavourite(int businessId) {
    bool result = false;
    if(state != null) {
      for(int i = 0; i < state!.length; i++) {
        if(state![i].business.id == businessId) {
          result = true;
        }
      }
    }
    return result;
  }

  void delete() {
    emit(null);
  }
}

class NearbyItemsCubit extends Cubit<List<ProductExpandedModel>> {

  NearbyItemsCubit(): super(List<ProductExpandedModel>.empty());

  void set(List<ProductExpandedModel> list) {
    emit(list);
  }

  void addItem(ProductExpandedModel item) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.add(item);
    emit(updatedState);
  }

  void setImageById({
    required int itemId,
    required ImageModel imageModel,
  }) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.firstWhere((i) => i.item.id == itemId).image = imageModel;
    emit(updatedState);
  }

  void removeItem(int itemId) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.removeWhere((i) => i.item.id == itemId);
    emit(updatedState);
  }

  void delete() {
    emit(List<ProductExpandedModel>.empty());
  }
}

class OrderHistoryCubit extends Cubit<List<ProductExpandedModel>> {

  OrderHistoryCubit(): super([]);

  set(List<ProductExpandedModel> value) {
    emit(value);
  }

  void delete() {
    emit([]);
  }
}

class RecommendedItemsCubit extends Cubit<List<ProductExpandedModel>> {

  RecommendedItemsCubit(): super(List<ProductExpandedModel>.empty());

  void set(List<ProductExpandedModel> list) {
    emit(list);
  }

  void addItem(ProductExpandedModel item) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.add(item);
    emit(updatedState);
  }

  void setImageById({
    required int itemId,
    required ImageModel imageModel,
  }) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.firstWhere((i) => i.item.id == itemId).image = imageModel;
    emit(updatedState);
  }

  void removeItem(int itemId) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.removeWhere((i) => i.item.id == itemId);
    emit(updatedState);
  }

  void delete() {
    emit(List<ProductExpandedModel>.empty());
  }
}

class PendingOrdersBusinessCubit extends Cubit<List<OrderModel>> {

  PendingOrdersBusinessCubit(): super([]);

  void setDeliveredWithQrById(int orderId) {
    List<OrderModel> updatedState = state;
    updatedState.firstWhere((i) => i.id == orderId).receptionMethod = 'QR';
    emit(updatedState);
  }

  void setWholeList(List<OrderModel> list) {
    emit(list);
  }

  void delete() {
    emit([]);
  }
}

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

  void setMediterranean(bool value) {
    Filters updatedState = state;
    updatedState.mediterranean = value;
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

  void delete() {
    emit(Filters());
  }
}

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

  void removePicture() {
    BusinessExpandedModel updatedState = state;
    updatedState.image = null;
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

  void setBankInfo({
    required String bankName,
    required String bankAccountType,
    required String bankAccount,
    required String bankOwnerName,
    required String interbankAccount,
  }) {
    BusinessExpandedModel updatedState = state;
    updatedState.business.bankName = bankName;
    updatedState.business.bankAccountType = bankAccountType;
    updatedState.business.bankAccount = bankAccount;
    updatedState.business.bankOwnerName = bankOwnerName;
    updatedState.business.interbankAccount = interbankAccount;
    emit(updatedState);
  }

  void delete() {
    emit(BusinessExpandedModel.empty());
  }
}

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