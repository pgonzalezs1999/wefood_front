import 'package:bloc/bloc.dart';
import 'package:wefood/models/product_model.dart';

class BusinessDinnerCubit extends Cubit<ProductModel?> {

  BusinessDinnerCubit(): super(null);

  void set(ProductModel? value) {
    emit(value);
  }
}