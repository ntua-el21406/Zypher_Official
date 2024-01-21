import 'package:my_zypher/screens/entry_screen.dart';
import '../core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:my_zypher/db.dart';

class LoginScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const LoginScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // text controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Extract the primary color from the theme or define it if it's a custom color
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset(Constants.fullLogoPath),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      //  Username Textbox
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
                    const SizedBox(height: 16),
                    SizedBox(
                      //  Password Textbox
                      width: 300,
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                //  Login Button
                onPressed: () async {
                  String username = usernameController.text;
                  String password = passwordController.text;
                  bool loggedIn =
                      await widget.dbHelper.loginUser(username, password);
                  if (loggedIn) {

                    
                    // var dbHelper = DatabaseHelper();

                    // await dbHelper.importCSVData();
                    
                    
                    
                    
                    int id =
                        await widget.dbHelper.getUserId(username, password);
                    // Display success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Login successful")),
                    );
                    // Navigate to Home Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryScreen(
                          dbHelper: widget.dbHelper,
                          id: id,
                        ),
                      ),
                    );
                  } else {
                    // Display error message for invalid credentials
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid credentials")),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.4, 36),
                  elevation: 5,
                ),
                child: const Text('Login'),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
