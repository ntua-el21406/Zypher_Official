import 'package:flutter/material.dart';
import '../components/activity_item.dart'; // Make sure to import the ActivityItem widget
import '../core/constants/constants.dart'; // Assuming you have this constants file
import 'package:my_zypher/db.dart';

class ActivitiesScreen extends StatelessWidget {
  final int id;
  final DatabaseHelper dbHelper;
  ActivitiesScreen({Key? key, required this.id, required this.dbHelper})
      : super(key: key);

  final List<Map<String, String>> activities = [
    // This list will eventually be populated with real data, possibly from a database
    {
      'carModel': 'Tesla Model S',
      'dateTime': 'Jan 1, 2024, 9:00 AM',
      'cost': '\$20'
    },
    // Add more items as needed...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Prevents the AppBar from showing a back arrow
        // AppBar details if any
      ),
      body: Column(
        children: [
          Center(
            child: Image.asset(Constants.singleLetterLogoPath),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          const Text(
            'Activities',
            textAlign: TextAlign
                .center, // This will center the text within its parent widget
            style: TextStyle(
              decoration:
                  TextDecoration.underline, // This will underline the text
              fontSize: 30.0, // Example for font size
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                var activity = activities[index];
                return ActivityItem(
                  carModel: activity['carModel']!,
                  dateTime: activity['dateTime']!,
                  cost: activity['cost']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
