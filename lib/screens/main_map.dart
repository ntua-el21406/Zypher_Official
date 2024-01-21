import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:my_zypher/db.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import './entry_screen.dart';
import '../components/user_role.dart';
import '/screens/location_search_screen.dart';

class MainMap extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const MainMap({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  State<MainMap> createState() => _MainMap();
}

class _MainMap extends State<MainMap> {
  late PolylinePoints polylinePoints;
  // late GoogleMapController _onMapCreated;

  //
  //
  //
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

  List<LatLng> polylineCoordinates = [];

  LocationData? currentLocation;
  GoogleMapController? mapController;

  void getCurrentLocation() {
    Location location = Location();

    location.getLocation().then((locationData) {
      currentLocation = locationData;
      // You can use the currentLocation variable now, it will have the location data
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      setState(() {});
    });
  }

  void _goToMyCurrentLocation() {
    // Method to animate the map to the current location
    // Ensure that currentLocation is updated with the user's current location
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    _goToMyCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          currentLocation == null
              ? const Center(child: Text('loading'))
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  // onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('Current Location'),
                      icon: currentLocationIcon,
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      infoWindow: const InfoWindow(title: 'Source'),
                    ),
                  },
                ),
          Positioned(
            top: MediaQuery.of(context)
                .padding
                .top, // Position right below the AppBar
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Tap to search...'),
                  onTap: () {
                    // Navigate to the search page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchLocationScreen(
                                id: widget.id,
                                dbHelper: widget.dbHelper,
                                userRole: widget.userRole,
                              )), // Replace with your search screen
                    );
                  },
                ),
              ),
            ),
          ),
          // Row for "Current Location" and "Choose Role" buttons
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 10, // Adjust as needed
            child: Row(
              children: [
                // "Current Location" button
                FloatingActionButton(
                  onPressed: () {
                    if (mapController != null && currentLocation != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                            zoom: 15,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.navigation),
                ),
                const SizedBox(width: 75), // Spacing between buttons

                // "Choose Role" button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryScreen(
                          id: widget.id,
                          dbHelper: widget.dbHelper,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary, // Use theme's secondary color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline,
                          color: Colors.white), // White icon for visibility
                      SizedBox(width: 8),
                      Text('Choose role',
                          style: TextStyle(
                              color:
                                  Colors.white)), // White text for visibility
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
