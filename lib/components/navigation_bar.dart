import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

Widget _buildNavItem(String iconPath, String label, Color bgColor) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20), // Adjust for rounded corners
    child: Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 25), // Padding inside the container
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, color: Colors.black), // Use your custom icon
            // Optionally add the label text below the icon
          ],
        ),
      ),
    ),
  );
}

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onIndexSelected;

  CustomBottomNavBar({
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).primaryColor;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildNavItem(Constants.homeIconPath, 'Home',
              widget.selectedIndex == 0 ? Colors.deepPurple : buttonColor),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(Constants.friendsIconPath, 'Friends',
              widget.selectedIndex == 1 ? Colors.deepPurple : buttonColor),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(Constants.activitiesIconPath, 'Activities',
              widget.selectedIndex == 2 ? Colors.deepPurple : buttonColor),
          label: 'Activities',
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(Constants.userIconPath, 'Profile',
              widget.selectedIndex == 3 ? Colors.deepPurple : buttonColor),
          label: 'Profile',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.deepPurple,
      onTap: widget.onIndexSelected,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );
  }
}
