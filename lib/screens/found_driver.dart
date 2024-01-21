import 'package:flutter/material.dart';
import 'package:my_zypher/db.dart';
import './main_screen.dart';
import '../components/user_role.dart';

class FoundDriverPage extends StatefulWidget {


  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;
  
  FoundDriverPage({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  State<FoundDriverPage> createState() => _FoundDriverPageState();
}

class _FoundDriverPageState extends State<FoundDriverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your driver is on the way!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                id: widget.id,
                                dbHelper: widget.dbHelper,
                                userRole: widget.userRole,
                              )), // Navigates to SearchingPage
                    );



                
                // Add your action here
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
