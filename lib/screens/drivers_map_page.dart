import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_zypher/db.dart';
import 'package:location/location.dart';
import 'package:my_zypher/screens/entry_screen.dart';
import './selection_page.dart';
import '../components/user_role.dart';
import './passenger_list.dart';
import './location_search_driver_screen.dart';

import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;






class DriversMapPage extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;
  // final String address_end;


  DriversMapPage({
    Key? key,
    // required this.address_end,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _DriversMapPage createState() => _DriversMapPage();
}

class _DriversMapPage extends State<DriversMapPage> {
  DatabaseHelper dbService = DatabaseHelper();

  GoogleMapController? mapController;
  Set<Marker> markers = {};

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  //
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "assets/Badge.png" // Assuming this is for a different marker
            )
        .then((icon) {
      currentLocationIcon = icon;
    });
  }








  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMarkerIcon();
    fetchAndPrintLocations();
    
    _goToMyCurrentLocation();
  }




















  
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

  // Future<void> _geocodeAddress(String address) async {
  //   location = null;
  //   try {
  //     List<Location> locations = await locationFromAddress(address);
  //     if (locations.isNotEmpty) {
  //       setState(() {
  //         location =
  //             LatLng(locations.first.latitude, locations.first.longitude);
  //       });
  //     }
  //   } catch (e) {
  //     print("Failed to get location: $e");
  //     // Handle exception or show an error message
  //   }
  // }

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













  // LocationData? currentLocation;
  // GoogleMapController? mapController;

  // // Future<void> getCurrentLocation() async {
  // //   Location location = Location();

  //   location.getLocation().then((locationData) {
  //     currentLocation = locationData;
  //     // You can use the currentLocation variable now, it will have the location data
  //   });

  //   location.onLocationChanged.listen((newLoc) {
  //     currentLocation = newLoc;

  //     setState(() {});
  //   });
  // }

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

  void fetchAndPrintLocations()  async{
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
        icon: currentLocationIcon,
      );
 

      newMarkers.add(marker);
    }

    await getCurrentLocation();
      // Check if currentLocation is not null and has valid coordinates
    if (currentLocation != null) {
      Marker marker2 = Marker(
        markerId: MarkerId('currentLocation'),
        position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        infoWindow: InfoWindow(title: 'My Current Location'),
      );

      newMarkers.add(marker2);
    } else {
      print("Current location is null or invalid");
    }



    setState(() {
      markers = newMarkers;
    });
  }



  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  // Function to load markers from database

  void onMarkerTap(Marker marker) {
    // var locations = await dbService.getLocations();
    // Show options (e.g., in a dialog or bottom sheet)
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.navigation),
              title: Text('Want to choose this User'),
              onTap: () async{

                var dbHelper= DatabaseHelper();
                                
                await dbHelper.updateLocationStatus(int.parse(marker.markerId.value));


                // ate to new page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectionPage(
                      marker: marker,
                      currentLocation: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      id: widget.id,
                      dbHelper: widget.dbHelper,
                      userRole: widget.userRole,
                      // locationId:
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // AppBar(
          //   title: Text('Users Close to you'),
          // ),
          currentLocation == null
              ? const Center(child: Text("loading"))
              : GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  markers: markers
                      .map((marker) => marker.copyWith(
                            onTapParam: () => onMarkerTap(marker),
                          ))
                      .toSet(),
                ),

           Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Tap to search...'),
            onTap: () {
              // Navigate to the search page
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
          ),
        ),
      ),
    ),
    Positioned(
      top: MediaQuery.of(context).padding.top + 60, // Adjust the top value as needed
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust padding as needed
        child: ElevatedButton(
          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PassengersListPage(
                  address: LatLng(0,0),
                  rangeInKm: 1000000000000,

                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Passenger List', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    ),
          

          // 'Current Location' and 'Choose Role' buttons
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 10, // Adjust as needed
            child: Row(
              children: [
                // 'Current Location' button
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
                  child: Icon(Icons.navigation),
                ),
                SizedBox(width: 75), // Spacing between buttons
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Choose role',
                          style: TextStyle(color: Colors.white)),
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
