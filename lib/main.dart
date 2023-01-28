import 'package:flutter/material.dart';
import 'package:self_test_map_tutorial/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '快篩地圖',
      theme: ThemeData(
        brightness: WidgetsBinding.instance.window.platformBrightness,
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}
