import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:self_test_map_tutorial/bloc/data_bloc.dart';
import 'package:self_test_map_tutorial/widgets/count_down_tile.dart';

import 'widgets/mark_popup_dialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _currentZoom = 15.0;
  final _bloc = DataBloc();
  final _mapController = MapController();
  final _popupController = PopupController();
  int _countDown = 120;
  final StreamController<int> _countDownStreamController =
      StreamController<int>();
  late Timer _countDownTimer;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Geolocator.getCurrentPosition();
  }

  Future<LatLng> _latlng() async {
    try {
      final position = await _determinePosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      late LatLng latlng;
      await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                contentPadding: const EdgeInsets.all(8.0),
                children: [
                  const Text("請開啟定位功能與權限以定位附近販售點"),
                  TextButton(
                      onPressed: () async {
                        final permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.deniedForever) {
                          latlng = LatLng(23.973875, 120.982024);
                        } else {
                          final position =
                              await Geolocator.getCurrentPosition();
                          latlng =
                              LatLng(position.latitude, position.longitude);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("確定"))
                ],
              ));
      return latlng;
    }
  }

  Timer _setTimer() => Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (_countDown != 0) {
            _countDown -= 1;
          } else {
            _bloc.add(FetchData());
            _countDown = 120;
          }
          _countDownStreamController.sink.add(_countDown);
        },
      );

  @override
  void initState() {
    super.initState();
    _countDownTimer = _setTimer();
    _bloc.add(FetchData());
  }

  @override
  void dispose() {
    _countDownTimer.cancel();
    _countDownStreamController.close();
    _bloc.close();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.my_location),
          onPressed: () async {
            final location = await _latlng();
            _mapController.move(location, _currentZoom);
          }),
      body: FutureBuilder<LatLng>(
          future: _latlng(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: snapshot.data,
                  zoom: _currentZoom,
                  onTap: (_, __) => _popupController.hideAllPopups(),
                  onPositionChanged: (_, __) =>
                      _currentZoom = _mapController.zoom,
                ),
                nonRotatedChildren: [
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CountDownTile(
                          stream: _countDownStreamController.stream,
                          onPressed: () {
                            _countDownTimer.cancel();
                            _bloc.add(FetchData());
                            _countDown = 120;
                            _countDownTimer = _setTimer();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                children: [
                  TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
                  CurrentLocationLayer(
                    positionStream: kIsWeb
                        ? const LocationMarkerDataStreamFactory()
                            .fromGeolocatorPositionStream(
                                stream: Geolocator.getPositionStream(
                                    locationSettings: const LocationSettings()))
                        : null,
                    style:
                        const LocationMarkerStyle(showHeadingSector: !kIsWeb),
                  ),
                  BlocBuilder<DataBloc, DataState>(
                      bloc: _bloc,
                      builder: (context, state) {
                        if (state is FinishState) {
                          return MarkerClusterLayerWidget(
                            options: MarkerClusterLayerOptions(
                              spiderfyCluster: false,
                              markers: state.sellerList
                                  .map((seller) => Marker(
                                        point: seller.latLng,
                                        builder: (context) => Icon(
                                          Icons.location_pin,
                                          size: 32.0,
                                          color: seller.remainAmount >= 25
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ))
                                  .toList(),
                              builder: (context, markers) => Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    markers.length <= 10
                                        ? markers.length.toString()
                                        : "10+",
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              popupOptions: PopupOptions(
                                popupState: PopupState(),
                                popupController: _popupController,
                                popupAnimation: const PopupAnimation.fade(),
                                markerTapBehavior:
                                    MarkerTapBehavior.togglePopupAndHideRest(),
                                popupBuilder: (context, marker) {
                                  final seller = state.sellerList.firstWhere(
                                      (element) =>
                                          element.latLng == marker.point);
                                  return SizedBox(
                                    width: 208,
                                    child: MarkerPopupDialog(
                                      info: seller,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      }),
                ],
              );
            }
            return Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 8.0),
                  Text("初始化中，請稍候")
                ],
              ),
            );
          }),
    );
  }
}
