import 'package:flutter/material.dart';

class Filters {
  double? maximumPrice;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool onlyToday = false;
  bool onlyAvailable = false;
  bool mediterranean = false;
  bool vegetarian = false;
  bool junk = false;
  bool dessert = false;
}

enum InputType {
  normal,
  secret,
  integer,
  decimal,
  date,
}

enum HttpType {
  get,
  post,
  multipartGet,
  multipartPost,
}

enum LoadingStatus {
  unset,
  loading,
  successful,
  error,
}

enum ProductType {
  breakfast,
  lunch,
  dinner,
}

enum OrderReceptionMethod {
  pm, // picked up manually
  normal,
}