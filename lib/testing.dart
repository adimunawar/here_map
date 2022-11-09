import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class TetingChart extends StatefulWidget {
  const TetingChart({super.key});

  @override
  State<TetingChart> createState() => _TetingChartState();
}

class _TetingChartState extends State<TetingChart> {
  @override
  void initState() {
    super.initState();
  }

  PolylinePoints polylinePoints = PolylinePoints();
  @override
  Widget build(BuildContext context) {
    List<List<MapLatLng>> polylines = [];
    List<MapLatLng> polyline = [];
    List<PointLatLng> result = polylinePoints.decodePolyline(
        "B2Fzv3jN4xwmtGwvQv3BjD3DgKwgBAsEoQAgFwRU_sBwMjDgKgtBTwHkcU8GoaUwC0KAgF0UAgFoVwCwCoQ8BAoGUTgKUnGkmBoBnGTT3DnBAjIjDTzFnBAzKTTrETA3DATnfwCnBzZnBnBrYvC7BvHnBT_JnBTjDTAzUvCnBnGAT_JkDnBrEAA7VzFvCvH7BTjI7BTrJvCAnQrET_JvCTnVjDTnGnBA7LTTnkB8BTjIUA_EATvRoBT_ToBAzKUT3NoBTzFoBArEkDTT4DATgFAUsJToBsJnBAsETTsEAjDoGT3DgFTrE4DAzFwCAzF8BAzF8BArJATnLAA3SnBTnQ7BA_O7BA7V7BT7VvCAjInBT7GTA3ITTvHAAvCAAjNoBTzF8BT_EoBAjIoBT3IUA3SATvlBnBnB_J7BA3DTAxBFA");
    for (var element in result) {
      polyline.add(MapLatLng(element.latitude, element.longitude));
    }
    polylines = <List<MapLatLng>>[polyline];

    print("ini ${polyline}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SfMaps(
              layers: [
                // MapTileLayer(
                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //   sublayers: [
                //     MapPolylineLayer(
                //       polylines: List<MapPolyline>.generate(
                //         polylines.length,
                //         (int index) {
                //           return MapPolyline(
                //             points: polylines[index],
                //           );
                //         },
                //       ).toSet(),
                //     ),
                //   ],
                //   zoomPanBehavior: MapZoomPanBehavior(
                //     zoomLevel: 12,
                //     focalLatLng: const MapLatLng(-6.8769172, 107.5857304),
                //   ),
                // ),
                MapShapeLayer(
                    sublayers: [
                      MapPolylineLayer(
                        polylines: List<MapPolyline>.generate(
                          polylines.length,
                          (int index) {
                            return MapPolyline(
                              points: polylines[index],
                            );
                          },
                        ).toSet(),
                      ),
                    ],
                    // zoomPanBehavior: MapZoomPanBehavior(
                    //   zoomLevel: 12,
                    //   focalLatLng: const MapLatLng(-6.8769172, 107.5857304),
                    // ),
                    strokeColor: Colors.grey,
                    source: const MapShapeSource.asset(
                      'assets/json/indonesia.json',
                      shapeDataField: 'PROVINSI',
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
