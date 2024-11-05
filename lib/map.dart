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
    distanceFilter: 100,
  );

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

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      logger.d(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          onTap: (latLng) => {
            logger.d(
                "latitude: ${latLng.latitude}, longitude: ${latLng.longitude}")
          },
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
            onPressed: () async {
              Position currentPosition = await Geolocator.getCurrentPosition(
                  locationSettings: locationSettings);
              logger.d(
                  '${currentPosition.latitude.toString()}, ${currentPosition.longitude.toString()}');

              final GoogleMapController controller = await _controller.future;
              final zoom = await controller.getZoomLevel();
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                      zoom: zoom),
                ),
              );
            },
            child: const Icon(Icons.near_me_outlined),
          ),
        ),
      ],
    );
  }
}
