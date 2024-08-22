import 'package:bloc/bloc.dart';
import 'package:wefood/models/models.dart';

class OrderHistoryCubit extends Cubit<List<ProductExpandedModel>> {

  OrderHistoryCubit(): super([]);

  set(List<ProductExpandedModel> value) {
    emit(value);
  }

  void delete() {
    emit([]);
  }
}