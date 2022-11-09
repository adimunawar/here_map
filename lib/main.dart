import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/routing.dart' as here;

void main() {
  _initializeHERESDK();
  runApp(const MyApp());
}

void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.

  String accessKeyId = "k2Ve0nzw2BcxXXicPw1_qQ";
  String accessKeySecret =
      "BHvL4ltVK9wOBDBSeIpgFzSLx-CbZjPsvN-H9px4MaDj2kfCVLwPUOCbzi457hJ4Sa2k5SLmhR1_rVr4Pi6YEw";
  SDKOptions sdkOptions =
      SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HereMapController? hereMapController;
  MapPolyline? mapPolyline;
  Position? _currentPosition;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Here Map Marker'),
          ),
          body: _currentPosition != null
              ? Column(
                  children: [
                    SizedBox(
                        height: 500,
                        child: HereMap(onMapCreated: _onMapCreated)),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    var geoCoordinates =
        GeoCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError? error) {
      if (error != null) {
        debugPrint('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }
    });
    _addMapMarker(geoCoordinates, hereMapController);
    drawRoute(geoCoordinates, GeoCoordinates(-6.8769172, 107.5857304),
        hereMapController);
    const double distanceToEarthInMeters = 8000;
    MapMeasure mapMeasureZoom =
        MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);

    hereMapController.camera
        .lookAtPointWithMeasure(geoCoordinates, mapMeasureZoom);
  }

  getCurrentLocation() async {
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

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      debugPrint(e);
    });

    // _addMarker(LatLng(_currentPosition.latitude, _currentPosition.longitude));
    // await getAddress();
  }

  void _addMapMarker(GeoCoordinates geoCoordinates,
      HereMapController hereMapController) async {
    ByteData fileData = await rootBundle.load('assets/icons/poi.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = 0;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawRoute(GeoCoordinates starts, GeoCoordinates end,
      HereMapController hereMapController) async {
    //creat route
    RoutingEngine routingEngine = RoutingEngine();
    //creat way point
    Waypoint starWayPoint = Waypoint.withDefaults(starts);
    Waypoint endWayPoint = Waypoint.withDefaults(end);
    List<Waypoint> wayPoints = [starWayPoint, endWayPoint];

    //calculate route

    routingEngine.calculateBicycleRoute(wayPoints, BicycleOptions(),
        (routingError, routes) {
      if (routingError == null) {
        var route = routes!.first;
        int estimatedTravelTimeInSeconds = route.duration.inSeconds;
        int lengthInMeters = route.lengthInMeters;
        GeoPolyline routeGeoPolyline = route.geometry;
        double debt = 20;
        mapPolyline = MapPolyline(
            routeGeoPolyline, debt, Color.fromARGB(160, 0, 144, 138));
        hereMapController.mapScene.addMapPolyline(mapPolyline!);
      }
    });
  }
}
