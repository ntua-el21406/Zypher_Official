import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:my_zypher/screens/searching_page.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;
import './main_screen.dart';
import 'package:my_zypher/db.dart';
import '../components/user_role.dart';

class RoutePage extends StatefulWidget {
  final String address_start;
  final String address_end;

  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const RoutePage({
    Key? key,
    required this.address_start,
    required this.address_end,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _RoutePage createState() => _RoutePage();
}

class _RoutePage extends State<RoutePage> {
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
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "assets/Pin_destination.png" // Assuming this is for a different marker
            )
        .then((icon) {
      destinationIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "assets/Badge.png" // Assuming this is for a different marker
            )
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

////////////TELOS EIKONIDION////////////////////

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
      print("Failed to get current location: $e");
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
      print("Failed to get location: $e");
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
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
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

  @override
  void initState() {
    super.initState();
    setupRoute();
    setCustomMarkerIcon();
  }

  void setupRoute() async {
    await getCurrentLocation();
    await _geocodeAddress(widget.address_end);
    location_end = location!;
    await _geocodeAddress(widget.address_start);
    location_start = location!;
    if (currentLocation != null && location != null) {
      await getPolyPoints(location_start!, location_end!);
    }
    calculateRouteDistance(polylineCoordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          location == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: location!,
                    zoom: 15,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Color(0xfff50000),
                      width: 6,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId('location'),
                      icon: destinationIcon,
                      position: location_start!,
                    ),
                    Marker(
                      markerId: MarkerId('location'),
                      icon: sourceIcon,
                      position: location_end!,
                    ),
                    Marker(
                      markerId: MarkerId("Current Location"),
                      icon: currentLocationIcon,
                      position: LatLng(currentLocation!.latitude,
                          currentLocation!.longitude),
                      infoWindow: InfoWindow(title: 'Source'),
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
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your trip is ${(totalDistance / 1000).toStringAsFixed(1)} km.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<int>(
                      future: widget.dbHelper.getUserPoints(widget.id),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show a loading indicator while waiting
                        } else if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Handle the error case
                        } else {
                          // Once the data is available, use it to build the UI
                          return Text(
                            'You have ${snapshot.data} points in your account.',
                            style: TextStyle(fontSize: 16),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Will you spend ${(totalDistance / 100).toStringAsFixed(0)} points to travel?',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var dbHelper = DatabaseHelper();
                            int locid = await dbHelper.insertLocation(
                              widget.id,
                              '${location_start!.latitude}',
                              '${location_start!.longitude}',
                              '${location_end!.latitude}',
                              '${location_end!.longitude}',
                              '0',
                            );

                            print("Inserted location with ID: $locid");

                            await dbHelper.updatePassengerPoints(
                                widget.id, (totalDistance ~/ 100).toInt());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchingPage(
                                  id: widget.id,
                                  dbHelper: widget.dbHelper,
                                  address_start: widget.address_start,
                                  address_end: widget.address_end,
                                  userRole: widget.userRole,
                                  locationid: locid,
                                ),
                              ), // Navigates to SearchingPage
                            );
                          },
                          child: Text('Search'),
                        ),
                        ElevatedButton(
                          onPressed: () {
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
