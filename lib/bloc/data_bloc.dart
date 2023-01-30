import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_test_map_tutorial/chopper/seller_data_service.dart';
import 'package:self_test_map_tutorial/models/seller_info.dart';

import 'data_event.dart';
import 'data_state.dart';

export 'data_state.dart';
export 'data_event.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final _chopperClient = ChopperClient(
      services: [SellerDataService.create()], converter: CsvConverter());
  DataBloc() : super(InitialState()) {
    on<FetchData>((event, emit) async {
      emit(LoadingState());
      final service = _chopperClient.getService<SellerDataService>();
      final result = await service.getInfo();
      if (result.isSuccessful) {
        final csvList = result.body!;
        final sellerList = csvList.map((e) => SellerInfo.fromList(e)).toList();
        emit(FinishState(sellerList));
      }
    });
  }
}
