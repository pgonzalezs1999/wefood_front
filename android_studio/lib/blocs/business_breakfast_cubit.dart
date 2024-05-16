import 'package:bloc/bloc.dart';
import 'package:wefood/models/product_model.dart';

class BusinessBreakfastCubit extends Cubit<ProductModel?> {

  BusinessBreakfastCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }

  void delete() {
    emit(null);
  }
}