// map_utils.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void goToMyCurrentLocation(
    GoogleMapController? mapController, LocationData? currentLocation) {
  if (currentLocation != null &&
      currentLocation.latitude != null &&
      currentLocation.longitude != null) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 15,
        ),
      ),
    );
  }
}
