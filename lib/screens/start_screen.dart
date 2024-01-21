import '../core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:my_zypher/db.dart';

class StartScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const StartScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // Login button
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(Constants.fullLogoPath), // Path to your logo image
            const SizedBox(height: 350),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 36),
                elevation: 5,
              ),
              child: const Text('Login'),
            ),

            const SizedBox(height: 5),

            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 10,
                    color: Colors.black,
                  ),
                ),
                Text('or'),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    indent: 10,
                    endIndent: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            ElevatedButton(
              // Sign Up button
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 36),
                elevation: 5,
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
