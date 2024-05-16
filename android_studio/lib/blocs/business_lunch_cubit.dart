import 'package:bloc/bloc.dart';
import 'package:wefood/models/product_model.dart';

class BusinessLunchCubit extends Cubit<ProductModel?> {

  BusinessLunchCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }

  void delete() {
    emit(null);
  }

}