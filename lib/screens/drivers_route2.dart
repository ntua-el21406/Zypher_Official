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
import './location_search_driver_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'selection_page.dart';

class RoutePageDriver extends StatefulWidget {
  // final String address_start;
  final String address_end;

  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const RoutePageDriver({
    Key? key,
    // required this.address_start,
    required this.address_end,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _RoutePageDriver createState() => _RoutePageDriver();
}

class _RoutePageDriver extends State<RoutePageDriver> {
  DatabaseHelper dbService = DatabaseHelper();
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
    
    setCustomMarkerIcon();
    // fetchAndPrintLocations();
    setupRoute();
  }

  void setupRoute() async {
    await getCurrentLocation();
    await _geocodeAddress(widget.address_end);
    location_end = location!;
    await _geocodeAddress("${currentLocation!.latitude!}, ${currentLocation!.longitude}");
    location_start = location!;
    if (currentLocation != null && location != null) {
      await getPolyPoints(location_start!, location_end!);
    }
    calculateRouteDistance(polylineCoordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchLocationDriverScreen(
                        id: widget.id,
                        dbHelper: widget.dbHelper,
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                child: AbsorbPointer( // Prevents the TextField from gaining focus
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: widget.address_end,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SvgPicture.asset(
                          "assets/icons/location_pin.svg",
                          color: secondaryColor40LightTheme,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ),



      body: Stack(children: <Widget>[
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
              // markers:markers
              //         .map((marker) => marker.copyWith(
              //               onTapParam: () => onMarkerTap(marker),
              //             ))
              //         .toSet(),
            ),
    ]));
  }
}
