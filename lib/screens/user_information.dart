import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import '../components/user_item.dart';
import 'package:my_zypher/db.dart';
import 'dart:io';

class UserInformationScreen extends StatefulWidget {
  final int id;
  final DatabaseHelper dbHelper;
  const UserInformationScreen(
      {Key? key, required this.id, required this.dbHelper})
      : super(key: key);

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController licencePlateController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();

  String userName = "";
  double rating = 5.0; // Assuming a default rating
  String imagePath = Constants.avatarPath; // Default image path

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    var userInfo = await widget.dbHelper.getUserInfo(widget.id);

    if (mounted) {
      setState(() {
        userName =
            "${userInfo['firstName'] ?? ''} ${userInfo['lastName'] ?? ''}";
        rating = userInfo['rating'] ?? 5.0;
        imagePath = userInfo['image_path'] ?? Constants.avatarPath;

        firstNameController.text = userInfo['firstName'] ?? '';
        lastNameController.text = userInfo['lastName'] ?? '';
        emailController.text = userInfo['email'] ?? '';
        usernameController.text = userInfo['username'] ?? '';
        passwordController.text = userInfo['password'] ?? '';
        licencePlateController.text = userInfo['licencePlate'] ?? '';
        carModelController.text = userInfo['carModel'] ?? '';
      });
    }
  }

  void _updateUserInfo() async {
    Map<String, dynamic> updatedData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'username': usernameController.text,
      'password': passwordController.text,
      'licencePlate': licencePlateController.text,
      'carModel': carModelController.text,
    };

    // Update user information in the database
    await widget.dbHelper.updateUser(widget.id, updatedData);

    // After updating the database, reload user information to update the UI
    _loadUserInfo();

    // Optionally, show a confirmation message or navigate back
    // For example:
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("User Information Updated")));
  }

  @override
  Widget build(BuildContext context) {
    // Image widget to display the user's image
    Widget userImage =
        imagePath != Constants.avatarPath && File(imagePath).existsSync()
            ? Image.file(File(imagePath))
            : Image.asset(Constants.avatarPath);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: SizedBox(
          height: kToolbarHeight, // Ensures the logo is not too tall
          child: Image.asset(Constants.singleLetterLogoPath),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                  height: 16), // Added margin between logo and user item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: UserItem(
                  name: userName,
                  rating: rating,
                  imageWidget:
                      ClipOval(child: userImage), // Pass the image widget here
                ),
              ),
              const SizedBox(
                  height: 16), // Added margin between user item and first input
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Email", emailController),
              _buildTextField("Username", usernameController),
              _buildTextField("Password", passwordController),
              _buildTextField("Licence Plate", licencePlateController),
              _buildTextField("Car Model", carModelController),
              const SizedBox(
                  height: 32), // Added margin before the Update button
              ElevatedButton(
                onPressed: _updateUserInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("Update Information"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 50.0), // Adjust padding as needed
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(), // Adds border to the TextField
          contentPadding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0), // Adjust padding inside TextField
        ),
        // Removed textAlign property for left alignment of input text
      ),
    );
  }
}
