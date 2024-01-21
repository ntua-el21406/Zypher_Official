import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_zypher/db.dart';
import 'package:location/location.dart';
import './selection_page.dart';
import '../components/user_role.dart';
import './passenger_list.dart';
import './location_search_driver_screen.dart';

import 'package:geocoding/geocoding.dart' as geocoded;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../core/constants/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:geodesy/geodesy.dart' as geo;

import './entry_screen.dart';






class RoutePageDriver extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;
  final String address_end;


  RoutePageDriver({
    Key? key,
    required this.address_end,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _RoutePageDriver createState() => _RoutePageDriver();
}

class _RoutePageDriver extends State<RoutePageDriver> {

      double rangeInKm=3.0;


  LatLng? location_end;
  LatLng? location_start;
  DatabaseHelper dbService = DatabaseHelper();

  // GoogleMapController? mapController;

  late GoogleMapController mapController;

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;

  //
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "assets/Badge.png" // Assuming this is for a different marker
            )
        .then((icon) {
      currentLocationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "assets/Pin_destination.png" // Assuming this is for a different marker
            )
        .then((icon) {
      destinationIcon = icon;
    });
  }


  LatLng? location; 
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
      List<geocoded.Location> locations = await geocoded.locationFromAddress(address);
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



    await _geocodeAddress(widget.address_end);

    location_end=location;





    var locations = await dbService.getLocationsClose(location_end!,rangeInKm);
    




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

          // var marker_end = Marker(
          //   markerId:
          //       MarkerId(location['id'].toString()), // Assuming there's an 'id'
          //   position: LatLng(
          //     double.parse(location['end_lat']
          //         .toString()), // Replace with your latitude key
          //     double.parse(location['end_lon']
          //         .toString()), // Replace with your longitude key
          //   ),
          //   infoWindow: InfoWindow(title: 'Marker ${location['id']}'),
          //   icon: currentLocationIcon,
          // );

          print("AAAAAAAAAAAAAAAAAAAAAAAA  FOUND MARKER NUMBER $location['id]");

          newMarkers.add(marker);
          
          // newMarkers.add(marker_end);





    }

    await getCurrentLocation();
      // Check if currentLocation is not null and has valid coordinates
    if (currentLocation != null) {
      Marker marker2 = Marker(
        markerId: MarkerId('currentLocation'),
        position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        infoWindow: InfoWindow(title: 'My Current Location'),
      );


      Marker marker3 = Marker(
        markerId: MarkerId('endLocation'),
        icon: destinationIcon,
        position: location_end!,
        infoWindow: InfoWindow(title: 'My Destination'),
      );

      newMarkers.add(marker2);
      newMarkers.add(marker3);
    } else {
      print("Current location is null or invalid");
    }

    if (currentLocation != null && location != null) {
      await getPolyPoints(currentLocation!, location_end!);
    }
    calculateRouteDistance(polylineCoordinates);


      Circle circle = Circle(
      circleId: CircleId('myCircle'), // Provide a unique id for the circle
      center: location_end!,
      radius: rangeInKm*1000,
      fillColor: const Color.fromARGB(59, 33, 149, 243).withOpacity(0.5),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    );



      



    setState(() {
      markers = newMarkers;
      circles = Set.from([circle]);
      location_end=location_end;
    });
  }



  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  // // Function to load markers from database

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

  void setupRoute() async {
    await getCurrentLocation();
    await _geocodeAddress(widget.address_end);
    location_end = location!;
    await _geocodeAddress("${currentLocation!.latitude},${currentLocation!.longitude}");
    location_start = location!;
    if (currentLocation != null && location != null) {
      await getPolyPoints(location_start!, location_end!);
    }
    calculateRouteDistance(polylineCoordinates);
    

  }

    @override
  void initState() {
    super.initState();

    getCurrentLocation();
    setCustomMarkerIcon();
    
    _goToMyCurrentLocation();

    // setupRoute();
    fetchAndPrintLocations();
    
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
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Color(0xfff50000),
                      width: 6,
                    ),
                  },
                  markers: markers.map((marker) => marker.copyWith(
                            onTapParam: () => onMarkerTap(marker),
                          ))
                      .toSet(),
                  circles: circles,
                ),

              Positioned(
              top: MediaQuery.of(context).padding.top, // Adjust the top value as needed
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
                          address: location_end!,
                          rangeInKm: rangeInKm,
                          // users_and_locations: locations,
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
