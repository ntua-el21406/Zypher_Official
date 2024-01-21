import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onCancel;

  LogoutConfirmationDialog({required this.onLogout, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout Confirmation'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text('Cancel'),
              ),
            ),
            TextButton(
              onPressed: onLogout,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text('Log Out'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
