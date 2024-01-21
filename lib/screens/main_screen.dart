import 'package:flutter/material.dart';
import '../components/navigation_bar.dart';
import './friends_screen.dart';
import './main_map.dart';
import 'activities_screen.dart';
import 'user_screen.dart';
import 'package:my_zypher/db.dart';
import './drivers_map_page.dart';
import '../components/user_role.dart';

// MainScreen.dart
class MainScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int id;
  final UserRole userRole;

  const MainScreen({
    Key? key,
    required this.dbHelper,
    required this.id,
    required this.userRole,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages;

    // Decide the first page based on the user role
    if (widget.userRole == UserRole.driver) {
      pages = [
        DriversMapPage(
            id: widget.id,
            dbHelper: widget.dbHelper,
            userRole: widget.userRole), // Driver's home page
        FriendsScreen(id: widget.id, dbHelper: widget.dbHelper),
        ActivitiesScreen(id: widget.id, dbHelper: widget.dbHelper),
        UserScreen(id: widget.id, dbHelper: widget.dbHelper),
      ];
    } else {
      pages = [
        MainMap(
          id: widget.id,
          dbHelper: widget.dbHelper,
          userRole: widget.userRole,
        ), // Passenger's home page
        FriendsScreen(id: widget.id, dbHelper: widget.dbHelper),
        ActivitiesScreen(id: widget.id, dbHelper: widget.dbHelper),
        UserScreen(id: widget.id, dbHelper: widget.dbHelper),
      ];
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onIndexSelected: _onNavBarItemTapped,
      ),
    );
  }
}
