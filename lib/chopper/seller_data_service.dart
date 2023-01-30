import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:csv/csv.dart';

part 'seller_data_service.chopper.dart';

typedef CsvRow = List<List<dynamic>>;

const baseUrl =
    "https://data.nhi.gov.tw/Datasets/Download.ashx?rid=A21030000I-D03001-001&l=https://data.nhi.gov.tw/resource/Nhi_Fst/Fstdata.csv";

@ChopperApi(baseUrl: baseUrl)
abstract class SellerDataService extends ChopperService {
  static SellerDataService create([ChopperClient? client]) =>
      _$SellerDataService(client);

  @Get()
  Future<Response<CsvRow>> getInfo();
}

class CsvConverter extends Converter {
  @override
  FutureOr<Request> convertRequest(Request request) => request;

  @override
  FutureOr<Response<CsvRow>> convertResponse<CsvRow, InnerType>(
      Response response) {
    if (response.statusCode == 200) {
      final dataString = utf8.decode(response.bodyBytes.toList());
      final datalist = const CsvToListConverter().convert(dataString);
      datalist.removeAt(0);
      return response.copyWith<CsvRow>(body: datalist as CsvRow);
    }
    return response.copyWith(body: response.body);
  }
}
