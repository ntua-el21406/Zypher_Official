import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

class ActivityItem extends StatelessWidget {
  final String carModel;
  final String dateTime;
  final String cost;

  const ActivityItem({
    Key? key,
    required this.carModel,
    required this.dateTime,
    required this.cost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFECE6F0), // Custom background color for the card
      elevation: 2, // Add shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners for the card
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2), // Border color
          width: 1, // Border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(Constants.carIconPath,
                  width: 75, height: 75), // Adjust the size as needed
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(carModel),
                  Text(dateTime),
                  Text(cost),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: 140, // Width of the Rate button
                  height: 40, // Height of the Rate button
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star, color: Colors.yellowAccent),
                    label: const Text('Rate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF7F2FA), // Background color
                      foregroundColor: const Color(0xFF6750A4), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners for the button
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Space between buttons
                SizedBox(
                  width: 140, // Width of the Add friend button
                  height: 40, // Height of the Add friend button
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add friend'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF7F2FA), // Background color
                      foregroundColor: const Color(0xFF6750A4), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners for the button
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
