import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/components/network.utility.dart';
import '/models/autocomplate_prediction.dart';
// import 'package:http/http.dart';
import '/components/location_list_tile.dart';
import '/core/constants/constants.dart';
// import '/screens/main_map.dart';
// import 'package:my_zypher/screens/route_screen_scheduled.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_zypher/screens/destination_search_screen.dart';
import 'package:location/location.dart';
import './main_screen.dart';
import 'package:my_zypher/db.dart';
import '/models/place_auto_complate_response.dart';
import '../components/user_role.dart';

class SearchLocationScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const SearchLocationScreen({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

List<LatLng> polylineCoordinates = [];

LocationData? currentLocation;
GoogleMapController? mapController;
LatLng? currentLatLng;

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePrediction> placePredictions = [];

  void placeAutocomplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
      "input": query,
      "key": google_api_key, // make sure you add your api key
    });
    // it's time to make the GET request
    //
    //
    String? response = await NetworkUtility.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  void getCurrentLocation() {
    Location location = Location();

    location.getLocation().then((locationData) {
      currentLocation = locationData;

      // Convert the LocationData to a LatLng object

      // You can now use the currentLatLng variable, which is a LatLng object
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      // Convert the LocationData to a LatLng object

      setState(() {
        // Update the UI with the new location data
      });
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: SvgPicture.asset(
              Constants.locationIconPath,
              height: 16,
              width: 16,
              color: secondaryColor40LightTheme,
            ),
          ),
        ),
        title: const Text(
          "Set Pickup Location",
          style: TextStyle(color: textColorLightTheme),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen(
                            id: widget.id,
                            dbHelper: widget.dbHelper,
                            userRole: widget.userRole,
                          )),
                );
              },
              icon: const Icon(Icons.close, color: Color(0xffe50808)),
            ),
          ),
          const SizedBox(width: defaultPadding)
        ],
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                onChanged: (value) {
                  placeAutocomplete(value);
                },
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  // When enter/search is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchDestinationScreen(
                            address: value,
                            id: widget.id,
                            dbHelper: widget.dbHelper,
                            userRole: widget
                                .userRole)), // Assuming OrderTrackingPage is the widget you want to navigate to
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search your location",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SvgPicture.asset(
                      "assets/icons/location_pin.svg",
                      color: secondaryColor40LightTheme,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchDestinationScreen(
                        address:
                            "${currentLocation!.latitude!}, ${currentLocation!.longitude}",
                        id: widget.id,
                        dbHelper: widget.dbHelper,
                        userRole: widget.userRole),
                  ),
                );
              },
              icon: SvgPicture.asset(
                "assets/icons/location.svg",
                height: 16,
              ),
              label: const Text("Use my Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor10LightTheme,
                foregroundColor: textColorLightTheme,
                elevation: 0,
                fixedSize: const Size(double.infinity, 40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: placePredictions.length,
              itemBuilder: (context, index) {
                final prediction = placePredictions[index];
                return LocationListTile(
                  press: () {
                    // You can use the `press` callback to navigate to the new page.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchDestinationScreen(
                            address: prediction.description!,
                            id: widget.id,
                            dbHelper: widget.dbHelper,
                            userRole: widget.userRole),
                      ),
                    );
                  },
                  location: prediction.description!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
