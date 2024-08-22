import 'package:bloc/bloc.dart';
import 'package:wefood/models/models.dart';

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