import 'package:bloc/bloc.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/models/user_model.dart';

class UserInfoCubit extends Cubit<BusinessExpandedModel> {

  UserInfoCubit(): super(BusinessExpandedModel.empty());

  void setUser(UserModel value) {
    BusinessExpandedModel updatedState = state;
    updatedState.user = value;
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
}