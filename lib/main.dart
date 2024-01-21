import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'db.dart';

void main() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.insertRandomLocations(100);
  await dbHelper.insertRandomUsers(100);

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;
  MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZYPHER',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(dbHelper: dbHelper),
        '/login': (context) => LoginScreen(dbHelper: dbHelper),
        '/signup': (context) => SignupScreen(dbHelper: dbHelper),
      },
    );
  }
}
