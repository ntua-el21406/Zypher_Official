import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import 'package:my_zypher/db.dart';
import 'package:image_picker/image_picker.dart'; // add line

class SignupCarScreen extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final DatabaseHelper dbHelper;

  const SignupCarScreen({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.dbHelper,
  }) : super(key: key);

  @override
  State<SignupCarScreen> createState() => _SignupCarScreenState();
}

class _SignupCarScreenState extends State<SignupCarScreen> {
  final TextEditingController licencePlateController = TextEditingController();
  final TextEditingController confirmLicencePlateController =
      TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Add this line

  String photo_path = '';

  Future<void> _takePhoto() async {
    // Add this method
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        // Process the photo as required
        // print('Photo path: ${photo.path}');
        // await widget.dbHelper.saveUserImage(userId, photo.path); // Replace `userId` with the actual user ID
        photo_path = photo.path;
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Image.asset(Constants.fullLogoPath),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Center(
                  child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: licencePlateController,
                      decoration: const InputDecoration(
                        labelText: 'Licence plate',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: confirmLicencePlateController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm licence plate',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: carModelController,
                      decoration: const InputDecoration(
                        labelText: 'Car model',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _takePhoto, // Update this line
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Adjust for rounded corners
                  ),
                  elevation: 2, // Adjust elevation for shadow
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Upload Photo'),
              ),
              const SizedBox(height: 150),
              ElevatedButton(
                onPressed: () async {
                  String licencePlate = licencePlateController.text;
                  String confirmLicencePlate =
                      confirmLicencePlateController.text;
                  String carModel = carModelController.text;

                  if (licencePlate.isNotEmpty &&
                      confirmLicencePlate.isNotEmpty &&
                      carModel.isNotEmpty) {
                    if (licencePlate == confirmLicencePlate) {
                      Map<String, dynamic> userData = {
                        'username': widget.usernameController.text,
                        'password': widget.passwordController.text,
                        'email': widget.emailController.text,
                        'firstName': widget.firstNameController.text,
                        'lastName': widget.lastNameController.text,
                        'licencePlate': licencePlate,
                        'carModel': carModel,
                        'image_path': photo_path,
                      };
                      // Call the insertUser method from DatabaseHelper
                      await widget.dbHelper.insertUser(userData);

                      // Show popup message for successful signup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Signup Successful")),
                      );

                      // Navigate to LoginScreen after successful sign up
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    } else {
                      // Show popup message if licence plates do not match
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Licence plates do not match")),
                      );
                    }
                  } else {
                    // Show popup message if some fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Fill in all the fields")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.4, 36),
                  elevation: 5,
                ),
                child: const Text('Sign up'),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
