import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import 'user_information.dart';
import '../components/user_item.dart';
import '../db.dart';
import 'dart:io';
import 'logout_confirmation_dialog.dart';

class UserScreen extends StatefulWidget {
  final int id;
  final DatabaseHelper dbHelper;
  const UserScreen({Key? key, required this.id, required this.dbHelper})
      : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String userName = "";
  double rating = 5.0; // Assuming a default rating
  String imagePath = Constants.avatarPath; // Default image path
  int totalPoints = 100000; // Assuming a default point value

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    Map<String, dynamic> userInfo =
        await widget.dbHelper.getUserInfo(widget.id);
    setState(() {
      userName = "${userInfo['firstName'] ?? ''} ${userInfo['lastName'] ?? ''}";
      rating = userInfo['rating'] ??
          5.0; // Update this if rating is part of your user data
      totalPoints = userInfo['points'] ??
          0; // Update this if totalPoints is part of your user data
      imagePath = userInfo['image_path'] ??
          Constants.avatarPath; // Update imagePath with the one from database
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imagePath != Constants.avatarPath && File(imagePath).existsSync()) {
      // If there is a user image path and it exists
      imageWidget = Image.file(File(imagePath));
    } else {
      // If the user image path is the default or does not exist
      imageWidget = Image.asset(Constants.avatarPath);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Constants.singleLetterLogoPath, height: 120),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              UserItem(
                name: userName,
                rating: rating,
                imageWidget: imageWidget, // Pass the image widget
              ),
              const SizedBox(height: 32),
              Text(
                "You have $totalPoints points in total",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to UserInformationScreen and await the result
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInformationScreen(
                        id: widget.id,
                        dbHelper: widget.dbHelper,
                      ),
                    ),
                  );
                  // Reload user data after returning
                  _loadUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Manage account"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Show the logout confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return LogoutConfirmationDialog(
                        onLogout: () {
                          // Handle the logout action here (e.g., navigate to the main page)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Logout Successful")),
                          );

                          // Navigate to LoginScreen after successful sign up
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        },
                        onCancel: () {
                          // Handle the cancel action here (e.g., go back to the user screen)
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
