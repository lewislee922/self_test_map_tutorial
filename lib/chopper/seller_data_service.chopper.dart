// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_data_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$SellerDataService extends SellerDataService {
  _$SellerDataService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = SellerDataService;

  @override
  Future<Response<List<List<dynamic>>>> getInfo() {
    final Uri $url = Uri.parse(
        'https://data.nhi.gov.tw/Datasets/Download.ashx?rid=A21030000I-D03001-001&l=https://data.nhi.gov.tw/resource/Nhi_Fst/Fstdata.csv');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<List<dynamic>>, List<dynamic>>($request);
  }
}
