import 'package:self_test_map_tutorial/models/seller_info.dart';

abstract class DataState {}

class InitialState implements DataState {}

class LoadingState implements DataState {}

class FinishState implements DataState {
  final List<SellerInfo> sellerList;

  FinishState(this.sellerList);
}
