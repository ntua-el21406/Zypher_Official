import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import './carpool_page_2.dart';
import 'package:my_zypher/db.dart';
import 'package:geodesy/geodesy.dart' as geo;
import '../components/user_role.dart';

class SelectionPage extends StatefulWidget {
  final Marker marker;
  final LatLng currentLocation;

  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  SelectionPage({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.marker,
    required this.currentLocation,
    required this.userRole,
  }) : super(key: key);

  @override
  _SelectionPage createState() => _SelectionPage();
}

class _SelectionPage extends State<SelectionPage> {
  List<LatLng> polylineCoordinates = [];

  @override
  @override
  void initState() {
    super.initState();

    // Scheduling the async call in the next microtask,
    // which is after initState() is complete but before the build method is called.
    Future.microtask(() async {
      // Assuming you have a method called getPolyPoints that you want to call here
      await getPolyPoints(widget.currentLocation, widget.marker.position);
      // And then calculateRouteDistance with the result
      calculateRouteDistance(polylineCoordinates);
    });
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

  Future<void> getPolyPoints(LatLng startPoint, LatLng endPoint) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key, // Google API Key
      PointLatLng(startPoint.latitude, startPoint.longitude),
      PointLatLng(endPoint.latitude, endPoint.longitude),
      // travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Creating a CameraPosition for the marker's location
    final CameraPosition initialCameraPosition = CameraPosition(
      target: widget.marker.position,
      zoom: 14.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Navigate to Passenger'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: {
                widget.marker,
                Marker(
                  markerId: MarkerId("Current Location"),
                  position: LatLng(widget.currentLocation.latitude,
                      widget.currentLocation.longitude),
                  infoWindow: InfoWindow(title: 'Source'),
                ),
              },
              // Set containing only the selected marker
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Color(0xfff50000),
                  width: 6,
                ),
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          // var dbHelper = DatabaseHelper();

          // await dbHelper.updateDriverPoints(widget.id, (totalDistance~/1000).toInt());

          // Navigate to CarpoolPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarpoolPage2(
                id: widget.id,
                dbHelper: widget.dbHelper,
                marker: widget.marker,
                location_id: widget.marker.markerId,
                userRole: widget.userRole,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20.0), // Adjust padding as needed
          child: Text('Got Passenger'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
