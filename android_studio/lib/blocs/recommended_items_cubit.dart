import 'package:bloc/bloc.dart';
import 'package:wefood/models/models.dart';

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
}