import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_zypher/db.dart';

class DriversMapPage extends StatefulWidget {
  @override
  _DriversMapScreenState createState() => _DriversMapScreenState();
}

class _DriversMapScreenState extends State<DriversMapPage> {
  DatabaseHelper dbService = DatabaseHelper();

  GoogleMapController? mapController;
  Set<Marker> markers = {};

  LatLng initialPosition = LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    fetchAndPrintLocations();
  }

  void fetchAndPrintLocations() async {
    var locations = await dbService.getLocations();
    // Assuming markers is a Set<Marker>
    Set<Marker> newMarkers = {};

    for (var location in locations) {
      print(location); // Print the location for debugging

      // Create a Marker from the location data
      var marker = Marker(
        markerId:
            MarkerId(location['id'].toString()), // Assuming there's an 'id'
        position: LatLng(
          double.parse(location['start_lat']
              .toString()), // Replace with your latitude key
          double.parse(location['start_lon']
              .toString()), // Replace with your longitude key
        ),
        infoWindow: InfoWindow(title: 'Marker ${location['id']}'),
      );

      newMarkers.add(marker);
    }

    setState(() {
      markers = newMarkers;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  // Function to load markers from database

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map with Markers'),
      ),
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 1.0,
        ),
        markers: markers,
      ),
    );
  }
}
