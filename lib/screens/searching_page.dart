import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;
import './entry_screen.dart';
import './main_screen.dart';
import 'package:my_zypher/db.dart';
import 'dart:async';
import './found_driver.dart';
import '../components/user_role.dart';

class SearchingPage extends StatefulWidget {
  final String address_start;
  final String address_end;
  final int locationid;

  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  SearchingPage({
    Key? key,
    required this.address_start,
    required this.address_end,
    required this.dbHelper,
    required this.id,
    required this.userRole,
    
    required this.locationid,
  }) : super(key: key);

  @override
  _SearchingPage createState() => _SearchingPage();
}

class _SearchingPage extends State<SearchingPage> {
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
    checkLocationStatus(widget.locationid.toString(), context);
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




  void checkLocationStatus(String locationId, BuildContext context) {
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      var dbHelper = DatabaseHelper();
      String status = await dbHelper.getLocationStatus(locationId);
      print("AAAAAAAAAAAAAAAA   AAAAAAAAAA  AAAAA   AAAAAAAAAAAAAA AA AAAAAAAAAA  AAAAAAACurrent status of location $locationId: $status");

      if (status == '1') {
        timer.cancel();
        print("AAAAAAAAAAAAAAAA   AAAAAAAAAA  AAAAA   AAAAAAAAAAAAAA AA AAAAAAAAAA  AAAAAAAStatus changed to 1 for location $locationId");

        // Redirect to a new page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FoundDriverPage(
            id: widget.id,
            dbHelper: widget.dbHelper,
            userRole: widget.userRole,
          )), // Replace NewPage with your destination page
        );
      }
    });
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
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      infoWindow: InfoWindow(title: 'Source'),
                    ),
                  },
                ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Searching for Driver',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(
                                  id: widget.id,
                                  dbHelper: widget.dbHelper,
                                  userRole: widget.userRole,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.grey),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                      onPressed: () async {
                        var dbHelper = DatabaseHelper();
                        await dbHelper.updateLocationStatus(widget.locationid);

                        // You can add more code here if you need to perform additional actions after the update
                      },
                      child: Text('Update'),
                    )

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
