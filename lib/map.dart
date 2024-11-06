import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapSampleState();
}

class MapSampleState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.68123428932672, 139.76714355230686),
    zoom: 14.4746,
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  bool trackingMode = true;
  bool pointerDown = false;

  @override
  void initState() {
    super.initState();

    Future(() async {
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
      } else if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (e) {
            logger.d('onPointerDown: $e');
            pointerDown = true;
          },
          onPointerUp: (e) {
            logger.d('onPointerUp: $e');
            pointerDown = false;
          },
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              logger.d('onMapCreated: $controller');

              _controller.complete(controller);

              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen((Position? position) async {
                if (position == null) {
                  logger.d('現在位置が取れなかった');
                  return;
                }

                logger.d(
                    '現在位置取得: ${position.latitude.toString()}, ${position.longitude.toString()}');

                if (trackingMode) {
                  final zoom = await controller.getZoomLevel();
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: zoom),
                    ),
                  );
                }
              });
            },
            onCameraMoveStarted: () {
              logger.d('onCameraMoveStarted');
              if (pointerDown) {
                setState(() {
                  trackingMode = false;
                });
              }
            },
            onTap: (latLng) {
              logger.d(
                  'onTap latitude: ${latLng.latitude}, longitude: ${latLng.longitude}');
            },
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(55, 55),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
            ),
            onPressed: !trackingMode
                ? () async {
                    logger.d('onPressed');

                    setState(() {
                      trackingMode = true;
                    });

                    Position position = await Geolocator.getCurrentPosition(
                        locationSettings: locationSettings);
                    logger.d(
                        '現在位置取得: ${position.latitude.toString()}, ${position.longitude.toString()}');

                    final GoogleMapController controller =
                        await _controller.future;
                    final zoom = await controller.getZoomLevel();
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target:
                                LatLng(position.latitude, position.longitude),
                            zoom: zoom),
                      ),
                    );
                  }
                : null,
            child: const Icon(Icons.near_me_outlined),
          ),
        ),
      ],
    );
  }

  void moveToCurrentPosition() {}
}
