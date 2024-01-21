import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './entry_screen.dart'; // Import the EntryScreen
import 'package:my_zypher/db.dart';
 // Make sure to import your DatabaseHelper class

class CarpoolPage extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final Marker marker;
  final location_id;

  CarpoolPage({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.location_id,
    required this.marker,
  }) : super(key: key);

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpool Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntryScreen(
                    id: id,
                    dbHelper: dbHelper,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Hello', style: TextStyle(fontSize: 24)),
      ),

      floatingActionButton: Container(
          width: 56, // Standard FAB size
          height: 56,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryScreen(
                      id: id,
                      dbHelper: dbHelper,
                    ),
                  ),
                );
              },
              child: Text('End Ride', style: TextStyle(fontSize: 10)), // Smaller text size to fit the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(56 / 2)), // Circular shape
              ),
            ),
          ),
        ),



    );
  }
}