import 'package:flutter/material.dart';
import 'package:my_zypher/screens/main_screen.dart';
import '../core/constants/constants.dart';
import 'package:my_zypher/db.dart';
import '../components/user_role.dart';
// enum UserRole { driver, passenger, none }

class EntryScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  const EntryScreen({Key? key, required this.dbHelper, required this.id})
      : super(key: key);

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  UserRole _selectedRole = UserRole.none;

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset(Constants.fullLogoPath,
                  height: MediaQuery.of(context).size.height * 0.2),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                'WELCOME TO THE NEW\nGENERATION OF TRAVELING',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Text(
                'Choose your role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20, // You can adjust the font size as needed
                  fontWeight: FontWeight.w300, // Lighter font weight
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = UserRole.driver;
                      });
                      navigateToMainScreen(UserRole.driver);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == UserRole.driver
                          ? buttonColor
                          : Colors.grey,
                      foregroundColor: Colors.white, // Button text color
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.4, 50),
                      elevation: 5,
                    ),
                    child: const Text('Driver'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = UserRole.passenger;
                      });
                      navigateToMainScreen(UserRole.passenger);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == UserRole.passenger
                          ? buttonColor
                          : Colors.grey,
                      foregroundColor: Colors.white, // Button text color
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.4, 50),
                      elevation: 5,
                    ),
                    child: const Text('Passenger'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToMainScreen(UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
            id: widget.id,
            dbHelper: widget.dbHelper,
            userRole: role // Pass the selected role
            ),
      ),
    );
  }
}
