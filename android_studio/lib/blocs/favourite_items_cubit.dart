import 'package:bloc/bloc.dart';
import 'package:wefood/models/models.dart';

class FavouriteItemsCubit extends Cubit<List<ProductExpandedModel>> {

  FavouriteItemsCubit(): super(List<ProductExpandedModel>.empty(growable: true));

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

  void removeItemByBusinessId(int businessId) {
    List<ProductExpandedModel> updatedState = state;
    updatedState.removeWhere((i) => i.business.id == businessId);
    emit(updatedState);
  }
}