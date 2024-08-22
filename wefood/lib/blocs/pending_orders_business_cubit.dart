import 'package:bloc/bloc.dart';
import 'package:wefood/models/models.dart';

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