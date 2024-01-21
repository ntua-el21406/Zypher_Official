import 'package:flutter/material.dart';
import '../core/constants/constants.dart'; // Adjust the import path as needed

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(Constants.singleLetterLogoPath),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFECE6F0),
                prefixIcon: const Icon(Icons.menu),
                hintText: 'Enter Starting Location...',
                suffixIcon: const Icon(Icons.search), // Added search icon
                border: InputBorder.none, // Remove the border
                // Maintain the circular shape with padding
                contentPadding: const EdgeInsets.all(12.0),
                // Apply a shape to the container of the TextField
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove the border
                  borderRadius: BorderRadius.circular(30.0), // Circular shape
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove the border
                  borderRadius: BorderRadius.circular(30.0), // Circular shape
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFECE6F0),
                prefixIcon: const Icon(Icons.menu),
                hintText: 'Enter Destination Location',
                suffixIcon: const Icon(Icons.search), // Added search icon
                border: InputBorder.none, // Remove the border
                // Maintain the circular shape with padding
                contentPadding: const EdgeInsets.all(12.0),
                // Apply a shape to the container of the TextField
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove the border
                  borderRadius: BorderRadius.circular(30.0), // Circular shape
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove the border
                  borderRadius: BorderRadius.circular(30.0), // Circular shape
                ),
              ),
            ),
            // Add additional content here
          ],
        ),
      ),
    );
  }
}
