// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;
import './main_screen.dart';
import 'package:my_zypher/db.dart';
import '../components/user_role.dart';

class CarpoolPage2 extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final Marker marker;
  final MarkerId location_id;
  final UserRole userRole;

  CarpoolPage2({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.location_id,
    required this.marker,
    required this.userRole,
  }) : super(key: key);

  @override
  _CarpoolPage2 createState() => _CarpoolPage2();
}

class _CarpoolPage2 extends State<CarpoolPage2> {
  late GoogleMapController mapController;
  LatLng? location; // Will hold the geocoded location
  LatLng? location_end;
  LatLng? location_start;

  LatLng? startPoint;

  LatLng? endPoint;

  late PolylinePoints polylinePoints;

//////////EIKONIDIA MONO//////////////////////////

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;

  //
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_source.png')
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            'assets/Pin_destination.png' // Assuming this is for a different marker
            )
        .then((icon) {
      destinationIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            'assets/Badge.png' // Assuming this is for a different marker
            )
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

////////////TELOS EIKONIDION////////////////////
//////////////////////////////////////////////////////////////////

  LatLng? currentLocation;

  Future<void> getCurrentLocation() async {
    loc.Location location = loc.Location();
    try {
      loc.LocationData locationData = await location.getLocation();
      setState(() {
        currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print('Failed to get current location: $e');
      // Handle exception (e.g., location services disabled)
    }
  }

  Future<void> _geocodeAddress(String address) async {
    location = null;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          location =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
      }
    } catch (e) {
      print('Failed to get location: $e');
      // Handle exception or show an error message
    }
  }

  List<LatLng> polylineCoordinates = [];

  Future<void> getPolyPoints(LatLng startPoint, LatLng endPoint) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key, // Google API Key
      PointLatLng(startPoint.latitude, startPoint.longitude),
      PointLatLng(endPoint.latitude, endPoint.longitude),
      // travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      setState(() {});
    }
  }

  double totalDistance = 0;

  double calculateRouteDistance(List<LatLng> polylineCoordinates) {
    final geo.Geodesy geodesyInstance = geo.Geodesy();
    totalDistance = 0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      LatLng start = polylineCoordinates[i];
      LatLng end = polylineCoordinates[i + 1];
      totalDistance += geodesyInstance.distanceBetweenTwoGeoPoints(
        geo.LatLng(start.latitude, start.longitude),
        geo.LatLng(end.latitude, end.longitude),
      );
    }

    return totalDistance / 1000; // Convert meters to kilometers
  }

  Map<String, dynamic>? locationData;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    setupRoute();
    setCustomMarkerIcon();
  }

  void setupRoute() async {
    await getCurrentLocation();

    var fetchedLocation = await widget.dbHelper
        .getLocationById(int.parse(widget.location_id.value));
    setState(() {
      locationData = fetchedLocation;
    });

    await _geocodeAddress(
        ' ${locationData!['start_lat']},${locationData!['start_lon']} ');
    location_start = location!;

    await _geocodeAddress(
        ' ${locationData!['end_lat']},${locationData!['end_lon']} ');
    location_end = location!;

    if (currentLocation != null && location != null) {
      await getPolyPoints(location_start!, location_end!);
    }

    calculateRouteDistance(polylineCoordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      location_end == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: location_start!,
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: polylineCoordinates,
                  color: const Color(0xfff50000),
                  width: 6,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('location'),
                  icon: destinationIcon,
                  position: location_start!,
                ),
                Marker(
                  markerId: const MarkerId('location'),
                  icon: sourceIcon,
                  position: location_end!,
                ),
                Marker(
                  markerId: const MarkerId('Current Location'),
                  icon: currentLocationIcon,
                  position: LatLng(
                      currentLocation!.latitude, currentLocation!.longitude),
                  infoWindow: const InfoWindow(title: 'Source'),
                ),
              },
            ),
      Positioned(
        bottom: 20, // Distance from the bottom of the screen
        left: 20, // Distance from the left edge of the screen
        right: 20, // Distance from the right edge of the screen
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your trip is ${(totalDistance / 1000).toStringAsFixed(1)} km.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'You will earn ${(totalDistance / 100).toStringAsFixed(0)} points.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    var dbHelper = DatabaseHelper();

                    await dbHelper.updateDriverPoints(
                        widget.id, totalDistance ~/ 100);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                id: widget.id,
                                dbHelper: widget.dbHelper,
                                userRole: widget.userRole,
                              )), // Navigates to SearchingPage
                    );
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.grey),
                  child: const Text('Ride finished'),
                ),
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}
