import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HERE SDK for Flutter - Hello Map!',
      home: HereMap(
        onMapCreated: _onMapViewCreated,
      ),
    );
  }

  void _onMapViewCreated(HereMapController controller) {
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalNight, (error) {
      if (error != null) {
        print("Map scene not loaded. MapError: $error");
      }

      double distanceToEarthInMeters = 8000;
      MapMeasure mapMeasureZoom =
          MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
      controller.camera.lookAtPointWithMeasure(
          GeoCoordinates(52.530932, 13.384915), mapMeasureZoom);
    });
  }
}
