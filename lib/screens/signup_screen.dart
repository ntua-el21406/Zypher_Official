import 'package:flutter/material.dart';
import 'package:my_zypher/screens/signup_car_screen.dart';
import '../core/constants/constants.dart';
import 'package:my_zypher/db.dart';

class SignupScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const SignupScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // text controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                    //  First Name Textfield
                    width: 300,
                    child: TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    //  Last Name Textfield
                    width: 300,
                    child: TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    //  Email Textfield
                    width: 300,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 40),
              Center(
                //  Username Textfield
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      //  Password Textfield
                      width: 300,
                      child: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      //  Confirm Textfield
                      width: 300,
                      child: TextField(
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                // 'Continue' Button
                onPressed: () {
                  if (firstNameController.text.isNotEmpty &&
                      lastNameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty) {
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupCarScreen(
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            emailController: emailController,
                            usernameController: usernameController,
                            passwordController: passwordController,
                            dbHelper: widget.dbHelper,
                          ),
                        ),
                      );
                    } else {
                      // Show popup message if passwords do not match
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Passwords do not match")),
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
                child: const Text('Continue'),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
