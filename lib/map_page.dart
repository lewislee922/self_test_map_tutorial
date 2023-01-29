import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _currentZoom = 15.0;

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
      late LatLng _latlng;
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
                          _latlng = LatLng(23.973875, 120.982024);
                        } else {
                          final _position =
                              await Geolocator.getCurrentPosition();
                          _latlng =
                              LatLng(_position.latitude, _position.longitude);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("確定"))
                ],
              ));
      return _latlng;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LatLng>(
          future: _latlng(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FlutterMap(
                options: MapOptions(center: snapshot.data, zoom: _currentZoom),
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
