import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_zypher/db.dart';
import './detail_page.dart';
import '../components/user_role.dart';

class PassengersListPage extends StatefulWidget {
  final LatLng address;
  final double rangeInKm;
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  PassengersListPage({
    Key? key,
    required this.address,
    required this.rangeInKm,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _PassengersListPageState createState() => _PassengersListPageState();
}

class _PassengersListPageState extends State<PassengersListPage> {
  List<Map<String, dynamic>> users_and_locations = []; // To store user data

  DatabaseHelper dbService = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Use the DatabaseHelper to get the data
    var queryResults = await dbService.getCloseUsersWithLocations(
      widget.address,
      widget.rangeInKm,
      widget.id,
    );

    // Update the state
    setState(() {
      users_and_locations = queryResults;
    });

    // No need to close the database here, as it is handled by the DatabaseHelper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passengers List'),
      ),
      body: ListView.builder(
        itemCount: users_and_locations.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                  users_and_locations[index]['username'] ?? 'Unknown User'),
              subtitle: Text(
                  '${users_and_locations[index]['firstName']} ${users_and_locations[index]['lastName']}'),
              trailing: ElevatedButton(
                child: Text('View Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        user_location: users_and_locations[index],
                        id: widget.id,
                        dbHelper: widget.dbHelper,
                        userRole: widget.userRole,
                      ), // Replace with your DetailPage
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
