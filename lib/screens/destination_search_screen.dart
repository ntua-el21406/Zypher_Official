import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_zypher/components/network.utility.dart';
import 'package:my_zypher/models/autocomplate_prediction.dart';
// import 'package:http/http.dart';
import '../components/location_list_tile.dart';
import '../core/constants/constants.dart';
// import 'package:my_zypher/screens/main_map.dart';
import 'package:my_zypher/screens/route_screen_passenger.dart';
import 'package:my_zypher/screens/location_search_screen.dart';
import 'package:my_zypher/models/place_auto_complate_response.dart';
import 'package:my_zypher/db.dart';
import '../components/user_role.dart';

class SearchDestinationScreen extends StatefulWidget {
  final String address;
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const SearchDestinationScreen({
    Key? key,
    required this.address,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  State<SearchDestinationScreen> createState() => _SearchDestinationScreen();
}

class _SearchDestinationScreen extends State<SearchDestinationScreen> {
  List<AutocompletePrediction> placePredictions = [];

  void placeAutocomplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
      "input": query,
      "key": google_api_key, // make sure you add your api key
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: SvgPicture.asset(
              "assets/icons/location.svg",
              height: 16,
              width: 16,
              color: secondaryColor40LightTheme,
            ),
          ),
        ),
        title: Text(
          "Set Dropoff Location",
          style: TextStyle(color: textColorLightTheme),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.address,
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
        actions: [
          CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchLocationScreen(
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
                      builder: (context) => RoutePage(
                          address_end: value,
                          address_start: widget.address,
                          id: widget.id,
                          dbHelper: widget.dbHelper,
                          userRole: widget.userRole),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search drop off location",
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
                        builder: (context) => RoutePage(
                            address_end: prediction.description!,
                            address_start: widget.address,
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
