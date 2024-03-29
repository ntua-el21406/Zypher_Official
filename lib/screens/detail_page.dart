import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;
import 'package:my_zypher/db.dart';
import './selection_page.dart';
import '../components/user_role.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> user_location;
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const DetailPage({
    Key? key,
    required this.user_location,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late GoogleMapController mapController;
  LatLng? location; // Will hold the geocoded location
  LatLng? location_end;
  LatLng? location_start;
  LatLng? startPoint;
  LatLng? endPoint;
  late PolylinePoints polylinePoints;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;

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

  Marker? selectedMarker; // Declare selectedMarker outside the function

  Future<void> createMarker() async {
    // Replace with your actual coordinates

    Marker marker = Marker(
        markerId: MarkerId(widget.user_location['id']
            .toString()), // Assuming widget.id is an int
        position: LatLng(double.tryParse(widget.user_location['start_lat'])!,
            double.tryParse(widget.user_location['start_lon'])!)
        // You can customize other properties of the marker here, such as icon, info window, etc.
        );

    selectedMarker = marker; // Assign the created marker to selectedMarker
  }

  @override
  void initState() {
    super.initState();
    setupRoute();
    setCustomMarkerIcon();
    createMarker();
  }

  void setupRoute() async {
    await getCurrentLocation();
    await _geocodeAddress(
        "${widget.user_location['end_lat']},${widget.user_location['end_lon']}");
    location_end = location!;
    await _geocodeAddress(
        "${widget.user_location['start_lat']},${widget.user_location['start_lon']}");
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
        title: Text(widget.user_location['username'] ?? 'User Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  widget.user_location['image_path'] ?? 'default_image_url'),
            ),
            const SizedBox(height: 20),
            Text(
              widget.user_location['username'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _detailItem('Email:', widget.user_location['email']),
            _detailItem('First Name:', widget.user_location['firstName']),
            _detailItem('Last Name:', widget.user_location['lastName']),
            // Add more details as needed

            const SizedBox(height: 20),
            _buildGoogleMap(),

            const SizedBox(height: 20),
            _buildRedirectButton(),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    if (polylineCoordinates.isEmpty) {
      // If polylineCoordinates are empty, you can show a loading spinner or a placeholder
      return const Center(child: CircularProgressIndicator());
    }

    // Example latitude and longitude. Replace with actual data.
    return Container(
      height: 300, // Set the height of the map
      child: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: LatLng(double.tryParse(widget.user_location['end_lat'])!,
              double.tryParse(widget.user_location['end_lon'])!),

          zoom: 14.0, // Adjust the zoom level as needed
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: const Color(0xfff50000),
            width: 6,
          ),
        },
        markers: Set.from([
          Marker(
            markerId: const MarkerId('userLocation'),
            position: LatLng(double.tryParse(widget.user_location['end_lat'])!,
                double.tryParse(widget.user_location['end_lon'])!),
          ),
          Marker(
            markerId: const MarkerId('userLocationStart'),
            position: LatLng(
                double.tryParse(widget.user_location['start_lat'])!,
                double.tryParse(widget.user_location['start_lon'])!),
            icon: currentLocationIcon,
          ),
        ]),
      ),
    );
  }

  Widget _buildRedirectButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionPage(
              id: widget.id,
              dbHelper: widget.dbHelper,
              userRole: widget.userRole,
              marker: selectedMarker!,
              currentLocation: currentLocation!,
              // Pass any necessary data to the SelectionPage
              // For example, you can pass widget.user_location or other details
            ),
          ),
        );
      },
      child: const Text('Choose this passenger'),
    );
  }
}
